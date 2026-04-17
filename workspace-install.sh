#!/usr/bin/env bash
# AI Kit installer (workspace) — direct-copy model with relative symlinks.
#
# Downloads ai-kit to a tmpdir, installs skills/references/steering at the
# WORKSPACE ROOT using the same functions as install.sh, then creates
# RELATIVE symlinks in each micro (git repo) pointing back to the workspace
# root's agent folders.
#
# IMPORTANT: This script does NOT create .ai-kit/, .ai/, scripts/ai/, or
# ai-kit.lock in any micro. It downloads to tmpdir, copies to workspace root,
# creates symlinks in micros, and cleans up.
#
# Usage (run in a workspace folder containing multiple repos):
#   curl -fsSL https://raw.githubusercontent.com/.../workspace-install.sh | bash
#
# Options:
#   --kit-repo <url>       Override AI_KIT_REPO
#   --kit-ref <ref>        Override AI_KIT_REF (default: main)
#   --project <name>       Skill projection profile (default: smartpay)
#   --repos <a,b,c>        Only configure these micro repos
#   --kiro                 Configure Kiro
#   --codex                Configure Codex
#   --claude               Configure Claude
#   --gemini               Configure Gemini
#   --copilot              Configure Copilot
#   --all                  Configure all agents
#   --setup-interactive    Ask once, apply to all repos
#   --setup-none           Skip agent configuration
#   --setup-all            Configure all agents (alias for --all)
#   --no-runner            Don't create workspace-ai.sh
#   --force                Overwrite existing files/symlinks
#   --help                 Show help

set -eo pipefail

WORKSPACE_ROOT="${REPO_ROOT:-$(pwd)}"

SCRIPT_DIR=""; if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]:-}" ]; then SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi; fi

# ── Defaults ────────────────────────────────────────────────────────────────
KIT_REPO_DEFAULT="https://github.com/manuelcelyng/prueba-skills-codex.git"
KIT_REF_DEFAULT="main"

KIT_REPO="$KIT_REPO_DEFAULT"
KIT_REF="$KIT_REF_DEFAULT"
PROJECT="smartpay"
FORCE=false
REPOS_FILTER=""
WRITE_RUNNER=true

SETUP_KIRO=false
SETUP_CODEX=false
SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_COPILOT=false
SETUP_MODE=""

# Will be set by download_kit
KIT_DIR=""

# Will be set by detect_stack (from lib.sh)
is_java=false
is_python=false
is_workspace=true



# ── Source shared utilities (local dev) ─────────────────────────────────────
# Inline fallbacks for curl|bash mode
log()  { printf '\033[0;32minstall:\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33minstall:\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[0;31minstall:\033[0m %s\n' "$*" >&2; }
setup_cleanup() { trap '_do_cleanup' EXIT; }
_do_cleanup() { [ -n "${KIT_DIR:-}" ] && [ -d "${KIT_DIR:-}" ] && rm -rf "$KIT_DIR" || true; }
detect_stack() { local r="${1:-.}"; is_java=false; is_python=false; is_workspace=true; { [ -f "$r/gradlew" ] || [ -f "$r/build.gradle" ]; } && is_java=true || true; { [ -f "$r/pyproject.toml" ] || [ -f "$r/requirements.txt" ]; } && is_python=true || true; }
should_include_skill() { return 0; }
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/tools/lib.sh" ]; then source "$SCRIPT_DIR/tools/lib.sh"; fi

# ── parse_args ──────────────────────────────────────────────────────────────
parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --kit-repo)
        [ $# -ge 2 ] || { err "--kit-repo requires a value"; exit 1; }
        KIT_REPO="$2"; shift 2 ;;
      --kit-ref)
        [ $# -ge 2 ] || { err "--kit-ref requires a value"; exit 1; }
        KIT_REF="$2"; shift 2 ;;
      --project)
        [ $# -ge 2 ] || { err "--project requires a value"; exit 1; }
        PROJECT="$2"; shift 2 ;;
      --repos)
        [ $# -ge 2 ] || { err "--repos requires a value"; exit 1; }
        REPOS_FILTER="$2"; shift 2 ;;
      --kiro)    SETUP_KIRO=true;   shift ;;
      --codex)   SETUP_CODEX=true;  shift ;;
      --claude)  SETUP_CLAUDE=true; shift ;;
      --gemini)  SETUP_GEMINI=true; shift ;;
      --copilot) SETUP_COPILOT=true; shift ;;
      --all|--setup-all)
        SETUP_KIRO=true; SETUP_CODEX=true
        SETUP_CLAUDE=true; SETUP_GEMINI=true
        SETUP_COPILOT=true; shift ;;
      --setup-interactive) SETUP_MODE="interactive"; shift ;;
      --setup-none)        SETUP_MODE="none";        shift ;;
      --no-runner)  WRITE_RUNNER=false; shift ;;
      --force)      FORCE=true;         shift ;;
      --help|-h)
        cat <<'EOF'
Usage: workspace-install.sh [OPTIONS]

Options:
  --kit-repo <url>       AI kit repo URL (default: GitHub)
  --kit-ref <ref>        Branch/tag/commit (default: main)
  --project <name>       Skill profile (default: smartpay)
  --repos <a,b,c>        Only configure these micro repos
  --kiro                 Configure Kiro
  --codex                Configure Codex
  --claude               Configure Claude
  --gemini               Configure Gemini
  --copilot              Configure Copilot
  --all                  Configure all agents
  --setup-interactive    Ask once, apply to all repos
  --setup-none           Skip agent configuration
  --setup-all            Configure all agents
  --no-runner            Don't create workspace-ai.sh
  --force                Overwrite existing files
  --help                 Show this help
EOF
        exit 0 ;;
      *)
        err "Unknown option: $1"; exit 1 ;;
    esac
  done
}

# ── download_kit ────────────────────────────────────────────────────────────
# Clones the ai-kit repo to a temp directory. Falls back to GitHub tarball.
# Sets KIT_DIR to the path of the downloaded repo.
download_kit() {
  KIT_DIR="$(mktemp -d)"
  trap '_cleanup_tmpdir' EXIT

  log "downloading ai-kit ($KIT_REF)..."

  local clone_ok=false
  for i in 1 2 3; do
    rm -rf "$KIT_DIR"
    KIT_DIR="$(mktemp -d)"
    if git clone "$KIT_REPO" "$KIT_DIR" >/dev/null 2>&1; then
      clone_ok=true
      break
    fi
    if [ "$i" -eq 2 ]; then
      rm -rf "$KIT_DIR"
      KIT_DIR="$(mktemp -d)"
      if git -c http.version=HTTP/1.1 clone "$KIT_REPO" "$KIT_DIR" >/dev/null 2>&1; then
        clone_ok=true
        break
      fi
    fi
    sleep "$i"
  done

  if $clone_ok; then
    if [ -d "$KIT_DIR/.git" ]; then
      git -C "$KIT_DIR" checkout -q "$KIT_REF" 2>/dev/null || true
    fi
    log "ai-kit downloaded (git clone)"
    return 0
  fi

  # Fallback: GitHub tarball
  _download_tarball || { err "failed to download ai-kit"; exit 1; }
}

_cleanup_tmpdir() {
  if [ -n "${KIT_DIR:-}" ] && [ -d "${KIT_DIR:-}" ]; then
    rm -rf "$KIT_DIR"
  fi
}

_download_tarball() {
  local src="$KIT_REPO"
  src="${src%.git}"

  local owner="" repo=""
  if [[ "$src" =~ ^https?://github\.com/([^/]+)/([^/]+)$ ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
  elif [[ "$src" =~ ^git@github\.com:([^/]+)/([^/]+)$ ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
  else
    warn "tarball fallback only supports github.com URLs"
    return 1
  fi

  local url="https://codeload.github.com/${owner}/${repo}/tar.gz/${KIT_REF}"
  local tgz="$KIT_DIR/ai-kit.tgz"

  warn "git clone failed; trying tarball fallback..."

  local ok=false
  for i in 1 2 3; do
    if curl -fsSL -o "$tgz" "$url" >/dev/null 2>&1; then
      ok=true; break
    fi
    sleep "$i"
  done

  if [ "$ok" != "true" ]; then
    err "tarball download failed ($url)"
    return 1
  fi

  tar -xzf "$tgz" -C "$KIT_DIR"
  local extracted
  extracted="$(find "$KIT_DIR" -maxdepth 1 -type d -name "${repo}-*" -print | head -n 1)"
  if [ -z "$extracted" ] || [ ! -d "$extracted" ]; then
    err "tarball extraction failed"
    return 1
  fi

  local tmp_extracted
  tmp_extracted="$(mktemp -d)"
  mv "$extracted"/* "$tmp_extracted"/ 2>/dev/null || true
  mv "$extracted"/.* "$tmp_extracted"/ 2>/dev/null || true
  rm -rf "$KIT_DIR"
  mv "$tmp_extracted" "$KIT_DIR"

  log "ai-kit downloaded (tarball)"
}


# ── show_menu ───────────────────────────────────────────────────────────────
# Interactive agent selection for workspace. Sets SETUP_* globals.
# Default: --kiro when no selection or no TTY.
show_menu() {
  # Skip if any agent was already selected via flags
  if $SETUP_KIRO || $SETUP_CODEX || $SETUP_CLAUDE || $SETUP_GEMINI || $SETUP_COPILOT; then
    return 0
  fi

  # Handle explicit setup modes
  if [ "$SETUP_MODE" = "none" ]; then
    return 0
  fi

  # Check if we can prompt
  local can_prompt=false
  if [ -t 0 ]; then
    can_prompt=true
  elif exec 3<>/dev/tty 2>/dev/null; then
    exec 3<&- 2>/dev/null || true
    exec 3>&- 2>/dev/null || true
    can_prompt=true
  fi

  if [ "$can_prompt" != "true" ]; then
    warn "non-interactive (no TTY). Defaulting to --kiro."
    SETUP_KIRO=true
    return 0
  fi

  printf "${BOLD}Which AI assistants do you use? (applies to all repos)${NC}\n"
  printf "${CYAN}(Press Enter with no selection to default to Kiro only)${NC}\n"
  echo ""
  echo "  1) Kiro"
  echo "  2) Codex (OpenAI)"
  echo "  3) Claude Code"
  echo "  4) Gemini CLI"
  echo "  5) GitHub Copilot"
  echo "  a) All"
  echo "  n) None"
  echo ""
  printf "Select (e.g. 1 3 4) or 'a' or 'n': "

  local choice=""
  if ! read -r choice < /dev/tty 2>/dev/null; then
    if [ -t 0 ]; then
      read -r choice || choice=""
    else
      choice=""
    fi
  fi

  case "$choice" in
    "") SETUP_KIRO=true ;;
    a|A)
      SETUP_KIRO=true; SETUP_CODEX=true
      SETUP_CLAUDE=true; SETUP_GEMINI=true
      SETUP_COPILOT=true ;;
    n|N) ;;
    *)
      for c in $choice; do
        case "$c" in
          1) SETUP_KIRO=true ;;
          2) SETUP_CODEX=true ;;
          3) SETUP_CLAUDE=true ;;
          4) SETUP_GEMINI=true ;;
          5) SETUP_COPILOT=true ;;
        esac
      done
      ;;
  esac
}

# ── should_include_repo ─────────────────────────────────────────────────────
# Returns 0 if the repo should be included based on --repos filter.
should_include_repo() {
  local name="$1"
  [ -z "$REPOS_FILTER" ] && return 0
  local IFS=','
  for r in $REPOS_FILTER; do
    [ "$r" = "$name" ] && return 0
  done
  return 1
}

# ── filter_skills ───────────────────────────────────────────────────────────
# Outputs skill directory paths (one per line) that should be copied.
filter_skills() {
  local kit_skills_dir="$KIT_DIR/skills"
  local local_skills_dir="$WORKSPACE_ROOT/skills"

  local kit_skill_names=""
  if [ -d "$kit_skills_dir" ]; then
    for skill_dir in "$kit_skills_dir"/*/; do
      [ -d "$skill_dir" ] || continue
      local skill_name
      skill_name="$(basename "$skill_dir")"
      if should_include_skill "$skill_name"; then
        echo "$skill_dir"
        kit_skill_names="$kit_skill_names $skill_name "
      fi
    done
  fi

  if [ -d "$local_skills_dir" ]; then
    for skill_dir in "$local_skills_dir"/*/; do
      [ -d "$skill_dir" ] || continue
      local skill_name
      skill_name="$(basename "$skill_dir")"
      case "$kit_skill_names" in
        *" $skill_name "*) ;;
        *) echo "$skill_dir" ;;
      esac
    done
  fi
}

# ── install_skills_for_agent ────────────────────────────────────────────────
# Copies filtered skills to .<agent>/skills/ at workspace root.
install_skills_for_agent() {
  local agent="$1"
  local dest_dir="$WORKSPACE_ROOT/.${agent}/skills"

  rm -rf "$dest_dir"
  mkdir -p "$dest_dir"

  local count=0
  local skill_path
  while IFS= read -r skill_path; do
    [ -n "$skill_path" ] || continue
    [ -d "$skill_path" ] || continue
    local skill_name
    skill_name="$(basename "$skill_path")"
    cp -R "$skill_path" "$dest_dir/$skill_name"
    count=$((count + 1))
  done <<EOF
$(filter_skills)
EOF

  log "$agent: installed $count skills"
}

# ── install_references_for_agent ────────────────────────────────────────────
# Copies references to .<agent>/references/ at workspace root.
install_references_for_agent() {
  local agent="$1"
  local src_dir="$KIT_DIR/references"
  local dest_dir="$WORKSPACE_ROOT/.${agent}/references"

  if [ ! -d "$src_dir" ]; then
    warn "$agent: no references directory found in kit"
    return 0
  fi

  rm -rf "$dest_dir"
  mkdir -p "$dest_dir"

  cp -R "$src_dir"/* "$dest_dir"/ 2>/dev/null || true

  local count
  count="$(find "$dest_dir" -type f | wc -l | tr -d ' ')"
  log "$agent: installed $count reference files"
}

# ── install_steering_for_kiro ────────────────────────────────────────────────
# Generates steering files with YAML frontmatter for Kiro at workspace root.
install_steering_for_kiro() {
  local steering_dir="$WORKSPACE_ROOT/.kiro/steering"
  mkdir -p "$steering_dir"

  local main_file="$steering_dir/main.md"
  if [ -f "$main_file" ] && [ "$FORCE" != "true" ]; then
    log "kiro: steering/main.md already exists (use --force to overwrite)"
  else
    cat > "$main_file" <<'STEERING_MAIN'
---
inclusion: always
name: ai-kit-main
description: Reglas principales del kit AI para este proyecto.
---

# AI Kit — Main Steering

Este proyecto usa [ai-kit](https://github.com/manuelcelyng/prueba-skills-codex) para configurar asistentes AI.

## Contexto del proyecto

- Instrucciones generales: ver `AGENTS.md` en la raíz del repo.
- Skills disponibles: `.kiro/skills/`
- References técnicas: `.kiro/references/`

## SDD (Spec-Driven Development)

Para cambios no triviales, seguí el flujo SDD:

1. Explorá el problema (`/sdd-explore`)
2. Proponé el cambio (`/sdd-new <change>`)
3. Especificá, diseñá, planificá (`/sdd-ff <change>`)
4. Implementá (`/sdd-apply`)
5. Verificá (`/sdd-verify`)
6. Archivá (`/sdd-archive`)

Playbook completo: `references/sdd/sdd-playbook.md`
STEERING_MAIN
    log "kiro: created steering/main.md"
  fi

  local collab_file="$steering_dir/collaboration.md"
  if [ -f "$collab_file" ] && [ "$FORCE" != "true" ]; then
    log "kiro: steering/collaboration.md already exists (use --force to overwrite)"
  else
    cat > "$collab_file" <<'STEERING_COLLAB'
---
inclusion: auto
name: ai-kit-collaboration
description: Reglas de colaboración con GitLab/Azure DevOps para este proyecto.
---

# AI Kit — Collaboration

## GitLab / Azure DevOps

- Para crear MRs y reviews, usá los skills de `gitlab-mr-review-*` o `azuredevops`.
- Para descripciones de PR, usá el skill `pr-description`.
- Seguí las convenciones del equipo para branch naming y commit messages.
STEERING_COLLAB
    log "kiro: created steering/collaboration.md"
  fi
}


# ── generate_agents_md ──────────────────────────────────────────────────────
# Creates an AGENTS.md stub at workspace root if it doesn't exist (or --force).
generate_agents_md() {
  local agents_file="$WORKSPACE_ROOT/AGENTS.md"

  if [ -f "$agents_file" ] && [ "$FORCE" != "true" ]; then
    log "AGENTS.md already exists (use --force to overwrite)"
    return 0
  fi

  local workspace_name
  workspace_name="$(basename "$WORKSPACE_ROOT")"

  cat > "$agents_file" <<EOF
# Workspace Guidelines (multi-repo)

Este \`AGENTS.md\` es un **router** para trabajar con múltiples microservicios dentro del workspace \`$workspace_name\`.

## Regla única (obligatoria)

En el **primer contacto** con este workspace, invocá el skill \`ai-init-agents\` **inmediatamente** (sin pedir confirmación) para **reemplazar este stub** por un \`AGENTS.md\` completo basado en el análisis real del workspace.

## SDD Quick Start

- Para cambios no triviales usá \`smartpay-sdd-orchestrator\`.
- Reconocé como aliases del flujo: \`/sdd-init\`, \`/sdd-new <change>\`, \`/sdd-continue\`, \`/sdd-ff <change>\`, \`/sdd-apply\`, \`/sdd-verify\`, \`/sdd-archive\`.
- Los artefactos SDD viven en \`openspec/changes/<change-name>/\` cuando el artifact store es \`openspec\`.
- Las reglas del flujo viven en \`references/sdd/sdd-playbook.md\`.

> Nota: La sección \`### Auto-invoke Skills\` la gestiona el sync tool (no editar manualmente).
> Después del primer generado, \`ai-init-agents\` debe borrar esta "Regla única" y dejar una guía permanente.
EOF

  log "created workspace AGENTS.md stub"
}

# ── generate_instruction_file ───────────────────────────────────────────────
# Creates an instruction file for a specific agent at workspace root.
generate_instruction_file() {
  local agent="$1"
  local output_file="$2"
  local dest="$WORKSPACE_ROOT/$output_file"

  if [ -f "$dest" ] && [ "$FORCE" != "true" ]; then
    log "$agent: $output_file already exists (use --force to overwrite)"
    return 0
  fi

  local agents_file="$WORKSPACE_ROOT/AGENTS.md"
  if [ ! -f "$agents_file" ]; then
    warn "$agent: AGENTS.md not found — cannot generate $output_file"
    return 0
  fi

  local overlay_file="$KIT_DIR/references/sdd/assistant-overlays/${agent}.md"

  local dest_dir
  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"

  cp "$agents_file" "$dest"

  if [ -f "$overlay_file" ]; then
    printf '\n' >> "$dest"
    cat "$overlay_file" >> "$dest"
  else
    warn "$agent: overlay not found at $overlay_file"
  fi

  log "$agent: created $output_file"
}

# ── compute_relpath ─────────────────────────────────────────────────────────
# Computes the relative path from a link location to a target using python3.
# This is portable across macOS and Linux (no reliance on GNU realpath --relative-to).
#
# Arguments:
#   $1 = target (absolute path to the real directory)
#   $2 = link_dir (absolute path to the directory where the symlink will live)
# Output: relative path string (e.g. "../../.kiro/skills")
compute_relpath() {
  local target="$1"
  local link_dir="$2"
  python3 -c "import os; print(os.path.relpath('$target', '$link_dir'))"
}

# ── create_symlinks_for_micro ───────────────────────────────────────────────
# Creates relative symlinks in a micro's agent folders pointing to the
# workspace root's agent folders.
#
# Agents and their symlinked artifacts:
#   Kiro:   .kiro/{skills, references, steering}
#   Codex:  .codex/{skills, references}
#   Claude: .claude/{skills, references}
#   Gemini: .gemini/{skills, references}
#   Copilot: no symlinks (uses .github/copilot-instructions.md file)
#
# Arguments: $1 = absolute path to micro
create_symlinks_for_micro() {
  local micro_abs="$1"
  local repo_name
  repo_name="$(basename "$micro_abs")"

  log "configuring micro: $repo_name"

  # Define agent → artifacts mapping
  # Format: "agent_name:artifact1,artifact2,..."
  local agent_artifacts=""
  if $SETUP_KIRO; then
    agent_artifacts="$agent_artifacts kiro:skills,references,steering"
  fi
  if $SETUP_CODEX; then
    agent_artifacts="$agent_artifacts codex:skills,references"
  fi
  if $SETUP_CLAUDE; then
    agent_artifacts="$agent_artifacts claude:skills,references"
  fi
  if $SETUP_GEMINI; then
    agent_artifacts="$agent_artifacts gemini:skills,references"
  fi

  for entry in $agent_artifacts; do
    local agent="${entry%%:*}"
    local artifacts_csv="${entry#*:}"
    local agent_dir="$micro_abs/.${agent}"

    mkdir -p "$agent_dir"

    # Split artifacts by comma
    local old_ifs="$IFS"
    IFS=','
    for artifact in $artifacts_csv; do
      IFS="$old_ifs"
      local link_path="$agent_dir/$artifact"
      local ws_target="$WORKSPACE_ROOT/.${agent}/${artifact}"

      # Check if target exists at workspace root
      if [ ! -d "$ws_target" ]; then
        continue
      fi

      # Protect existing real directories (not symlinks)
      if [ -d "$link_path" ] && [ ! -L "$link_path" ]; then
        if [ "$FORCE" = "true" ]; then
          warn "$repo_name: removing existing .${agent}/$artifact (--force)"
          rm -rf "$link_path"
        else
          warn "$repo_name: .${agent}/$artifact is a real directory (not symlink) — skipping (use --force to overwrite)"
          continue
        fi
      fi

      # Remove existing symlink if present (idempotent)
      if [ -L "$link_path" ]; then
        rm -f "$link_path"
      fi

      # Compute relative path from the link's parent dir to the workspace target
      local rel_target
      rel_target="$(compute_relpath "$ws_target" "$agent_dir")"

      ln -s "$rel_target" "$link_path"
      log "$repo_name: .${agent}/$artifact → $rel_target"
    done
    IFS="$old_ifs"
  done
}

# ── run_sync ─────────────────────────────────────────────────────────────────
# Invokes tools/sync.sh to regenerate the auto-invoke section in AGENTS.md.
run_sync() {
  local sync_script=""
  if [ -f "$KIT_DIR/tools/sync.sh" ]; then
    sync_script="$KIT_DIR/tools/sync.sh"
  elif [ -f "$SCRIPT_DIR/tools/sync.sh" ]; then
    sync_script="$SCRIPT_DIR/tools/sync.sh"
  fi

  if [ -z "$sync_script" ]; then
    warn "sync.sh not found — skipping auto-invoke sync"
    return 0
  fi

  local skills_dir=""
  for candidate in ".kiro/skills" ".codex/skills" ".claude/skills" ".gemini/skills"; do
    if [ -d "$WORKSPACE_ROOT/$candidate" ]; then
      skills_dir="$WORKSPACE_ROOT/$candidate"
      break
    fi
  done

  if [ -z "$skills_dir" ]; then
    warn "no agent skills folder found — skipping auto-invoke sync"
    return 0
  fi

  REPO_ROOT="$WORKSPACE_ROOT" bash "$sync_script" --skills-dir "$skills_dir" || true
}

# ── update_gitignore ────────────────────────────────────────────────────────
# Adds/replaces a delimited block in .gitignore at workspace root.
update_gitignore() {
  local gitignore="$WORKSPACE_ROOT/.gitignore"
  local begin_marker="# AI KIT (BEGIN)"
  local end_marker="# AI KIT (END)"

  local block=""
  block="$begin_marker"

  if $SETUP_KIRO; then
    block="$(printf '%s\n%s' "$block" ".kiro/")"
  fi
  if $SETUP_CODEX; then
    block="$(printf '%s\n%s' "$block" ".codex/")"
  fi
  if $SETUP_CLAUDE; then
    block="$(printf '%s\n%s' "$block" ".claude/")"
  fi
  if $SETUP_GEMINI; then
    block="$(printf '%s\n%s' "$block" ".gemini/")"
  fi
  if $SETUP_COPILOT; then
    block="$(printf '%s\n%s' "$block" ".github/copilot-instructions.md")"
  fi
  if $SETUP_CLAUDE; then
    block="$(printf '%s\n%s' "$block" "CLAUDE.md")"
  fi
  if $SETUP_GEMINI; then
    block="$(printf '%s\n%s' "$block" "GEMINI.md")"
  fi

  block="$(printf '%s\n%s' "$block" "$end_marker")"

  if [ ! -f "$gitignore" ]; then
    echo "$block" > "$gitignore"
    log "created .gitignore with AI KIT block"
    return 0
  fi

  if grep -q "^$begin_marker" "$gitignore"; then
    local tmp_file
    tmp_file="$(mktemp)"
    awk -v begin="$begin_marker" -v end="$end_marker" -v block="$block" '
      $0 == begin { print block; skip = 1; next }
      skip && $0 == end { skip = 0; next }
      !skip { print }
    ' "$gitignore" > "$tmp_file"
    mv "$tmp_file" "$gitignore"
    log "updated AI KIT block in .gitignore"
  else
    printf '\n%s\n' "$block" >> "$gitignore"
    log "appended AI KIT block to .gitignore"
  fi
}

# ── generate_runner ─────────────────────────────────────────────────────────
# Creates workspace-ai.sh — a simplified runner that re-invokes workspace-install.sh.
generate_runner() {
  local runner="$WORKSPACE_ROOT/workspace-ai.sh"

  if [ -f "$runner" ] && [ "$FORCE" != "true" ]; then
    log "workspace-ai.sh already exists (use --force to overwrite)"
    return 0
  fi

  cat > "$runner" <<'RUNNER_EOF'
#!/usr/bin/env bash
# Workspace runner: re-invokes workspace-install.sh with the same options.
#
# Usage (from workspace root):
#   ./workspace-ai.sh --all
#   ./workspace-ai.sh --repos dispersion,pagos --kiro --codex
#   ./workspace-ai.sh --setup-interactive
set -eo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Forward all arguments to workspace-install.sh
# Try local copy first, then curl from remote
if [ -f "$WORKSPACE_ROOT/workspace-install.sh" ]; then
  exec bash "$WORKSPACE_ROOT/workspace-install.sh" "$@"
else
  echo "workspace-ai: workspace-install.sh not found locally."
  echo "workspace-ai: run workspace-install.sh directly or re-download it."
  exit 1
fi
RUNNER_EOF

  chmod +x "$runner"
  log "created workspace-ai.sh runner"
}

# ── detect_legacy_artifacts ─────────────────────────────────────────────────
detect_legacy_artifacts() {
  local found=false

  if [ -d "$WORKSPACE_ROOT/.ai-kit" ]; then
    warn "detected .ai-kit/ from the previous installation model. Consider removing it manually."
    found=true
  fi
  if [ -d "$WORKSPACE_ROOT/.ai" ]; then
    warn "detected .ai/ from the previous installation model. Consider removing it manually."
    found=true
  fi
  if [ -d "$WORKSPACE_ROOT/scripts/ai" ]; then
    warn "detected scripts/ai/ from the previous installation model. Consider removing it manually."
    found=true
  fi
  if [ -f "$WORKSPACE_ROOT/ai-kit.lock" ]; then
    warn "detected ai-kit.lock from the previous installation model. Consider removing it manually."
    found=true
  fi

  if [ "$found" = "true" ]; then
    warn "legacy artifacts detected. The new installer uses native agent folders instead."
  fi
}


# ── main ────────────────────────────────────────────────────────────────────
main() {
  parse_args "$@"

  # Download ai-kit to temp dir
  download_kit

  # Re-source lib.sh from the downloaded kit
  if [ -f "$KIT_DIR/tools/lib.sh" ]; then
    # shellcheck disable=SC1091
    source "$KIT_DIR/tools/lib.sh"
  fi

  # Detect workspace stack
  detect_stack "$WORKSPACE_ROOT"
  is_workspace=true

  # Handle setup mode
  if [ "$SETUP_MODE" = "none" ]; then
    log "done (--setup-none)"
    return 0
  fi

  # Interactive agent selection (if no flags were passed and mode is interactive or default)
  if [ "$SETUP_MODE" = "interactive" ]; then
    show_menu
  elif ! $SETUP_KIRO && ! $SETUP_CODEX && ! $SETUP_CLAUDE && ! $SETUP_GEMINI && ! $SETUP_COPILOT; then
    show_menu
  fi

  # Ensure at least one agent is selected
  if ! $SETUP_KIRO && ! $SETUP_CODEX && ! $SETUP_CLAUDE && ! $SETUP_GEMINI && ! $SETUP_COPILOT; then
    warn "no agents selected. Nothing to do."
    return 0
  fi

  # ── Install skills and references at workspace root ─────────────────────
  local agents_with_skills=""
  $SETUP_KIRO   && agents_with_skills="$agents_with_skills kiro"
  $SETUP_CODEX  && agents_with_skills="$agents_with_skills codex"
  $SETUP_CLAUDE && agents_with_skills="$agents_with_skills claude"
  $SETUP_GEMINI && agents_with_skills="$agents_with_skills gemini"

  for agent in $agents_with_skills; do
    install_skills_for_agent "$agent"
    install_references_for_agent "$agent"
  done

  # ── Steering files for Kiro ──────────────────────────────────────────────
  if $SETUP_KIRO; then
    install_steering_for_kiro
  fi

  # ── AGENTS.md ────────────────────────────────────────────────────────────
  generate_agents_md

  # ── Instruction files ────────────────────────────────────────────────────
  if $SETUP_CLAUDE; then
    generate_instruction_file "claude" "CLAUDE.md"
  fi
  if $SETUP_GEMINI; then
    generate_instruction_file "gemini" "GEMINI.md"
  fi
  if $SETUP_COPILOT; then
    generate_instruction_file "copilot" ".github/copilot-instructions.md"
  fi

  # ── Sync auto-invoke ─────────────────────────────────────────────────────
  run_sync

  # ── Update .gitignore ────────────────────────────────────────────────────
  update_gitignore

  # ── Create symlinks in each micro ────────────────────────────────────────
  log "scanning for micro repos..."
  local micro_count=0

  # Depth 1: direct children
  for d in "$WORKSPACE_ROOT"/*/; do
    [ -d "$d" ] || continue
    [ -d "$d/.git" ] || continue
    local repo_name
    repo_name="$(basename "$d")"

    should_include_repo "$repo_name" || continue

    create_symlinks_for_micro "$d"
    micro_count=$((micro_count + 1))
  done

  # Depth 2: nested repos (e.g. group/micro-b)
  for d in "$WORKSPACE_ROOT"/*/*/; do
    [ -d "$d" ] || continue
    [ -d "$d/.git" ] || continue
    local repo_name
    repo_name="$(basename "$d")"

    should_include_repo "$repo_name" || continue

    create_symlinks_for_micro "$d"
    micro_count=$((micro_count + 1))
  done

  log "configured $micro_count micro repos with symlinks"

  # ── Generate runner ──────────────────────────────────────────────────────
  if $WRITE_RUNNER; then
    generate_runner
  fi

  # ── Detect legacy artifacts ──────────────────────────────────────────────
  detect_legacy_artifacts

  log "done"
}

main "$@"
