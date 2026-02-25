#!/usr/bin/env bash
# AI Kit installer (workspace).
#
# Intended usage (run in a folder that contains multiple repos):
#   curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/workspace-install.sh | bash
#
# Options:
#   --kit-repo <git-url>   Override AI_KIT_REPO
#   --kit-ref <ref>        Override AI_KIT_REF (default: main)
#   --project <name>       Skill projection profile (e.g. asulado|smartpay)
#   --repos a,b,c          Only install into these repo folder names
#   --setup-all            Configure all assistants
#   (default)              Configure Codex only
#   --setup-interactive    Prompt once and apply to all repos
#   --setup-none           Skip setup step for all repos
#   --no-runner            Don't create/update a workspace-ai.sh runner in the workspace root
#   --no-run               Only install files; don't run bootstrap/setup/sync
#   --force                Overwrite existing files

set -euo pipefail

KIT_REPO_DEFAULT="https://github.com/manuelcelyng/prueba-skills-codex.git"
KIT_REF_DEFAULT="main"

KIT_REPO="$KIT_REPO_DEFAULT"
KIT_REF="$KIT_REF_DEFAULT"
PROJECT=""
REPOS_FILTER=""
NO_RUN=false
FORCE=false
SETUP_MODE="codex"
SETUP_ARGS=()
WRITE_RUNNER=true

usage() {
  cat <<EOF
Usage: workspace-install.sh [--kit-repo <git-url>] [--kit-ref <ref>] [--project <name>] [--repos a,b,c] [--no-run] [--force]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kit-repo)
      [ $# -ge 2 ] || { echo "workspace-install: --kit-repo requires a value" >&2; exit 1; }
      KIT_REPO="$2"; shift 2 ;;
    --kit-ref)
      [ $# -ge 2 ] || { echo "workspace-install: --kit-ref requires a value" >&2; exit 1; }
      KIT_REF="$2"; shift 2 ;;
    --project)
      [ $# -ge 2 ] || { echo "workspace-install: --project requires a value" >&2; exit 1; }
      PROJECT="$2"; shift 2 ;;
    --repos)
      [ $# -ge 2 ] || { echo "workspace-install: --repos requires a value" >&2; exit 1; }
      REPOS_FILTER="$2"; shift 2 ;;
    --setup-all) SETUP_MODE="all"; shift ;;
    --setup-none) SETUP_MODE="none"; shift ;;
    --setup-interactive) SETUP_MODE="interactive"; shift ;;
    --no-runner) WRITE_RUNNER=false; shift ;;
    --no-run) NO_RUN=true; shift ;;
    --force) FORCE=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

WORKSPACE_ROOT="$(pwd)"

should_include() {
  local name="$1"
  [ -z "$REPOS_FILTER" ] && return 0
  local IFS=','
  for r in $REPOS_FILTER; do
    [ "$r" = "$name" ] && return 0
  done
  return 1
}

tmpdir="$(mktemp -d)"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT

kitdir="$tmpdir/ai-kit"
git clone "$KIT_REPO" "$kitdir" >/dev/null
git -C "$kitdir" fetch --all --tags >/dev/null 2>&1 || true
git -C "$kitdir" checkout -q "$KIT_REF"

installer="$kitdir/install.sh"
chmod +x "$installer"

if [ "$SETUP_MODE" = "none" ]; then
  SETUP_ARGS+=(--no-setup)
elif [ "$SETUP_MODE" = "all" ]; then
  SETUP_ARGS+=(--all)
elif [ "$SETUP_MODE" = "codex" ]; then
  SETUP_ARGS+=(--codex)
elif [ "$SETUP_MODE" = "interactive" ]; then
  # Ask once, apply to all repos.
  echo "workspace-install: choose assistants (applies to all repos)"
  if [ -r /dev/tty ]; then
    echo "  1) Claude"
    echo "  2) Gemini"
    echo "  3) Codex"
    echo "  4) Copilot"
    echo "  a) All"
    echo "  n) None"
    echo -n "Select (e.g. 1 3 4) or 'a' or 'n': "
    choice=""
    if ! read -r choice < /dev/tty 2>/dev/null; then
      choice=""
    fi
    case "$choice" in
      "") SETUP_ARGS+=(--codex) ;;
      a|A) SETUP_ARGS+=(--all) ;;
      n|N) SETUP_ARGS+=(--no-setup) ;;
      *)
        # split on spaces
        for c in $choice; do
          case "$c" in
            1) SETUP_ARGS+=(--claude) ;;
            2) SETUP_ARGS+=(--gemini) ;;
            3) SETUP_ARGS+=(--codex) ;;
            4) SETUP_ARGS+=(--copilot) ;;
          esac
        done
        ;;
    esac
  else
    # Non-interactive: safest default
    SETUP_ARGS+=(--codex)
  fi
fi

for d in "$WORKSPACE_ROOT"/*; do
  [ -d "$d" ] || continue
  [ -d "$d/.git" ] || continue
  repo_name="$(basename "$d")"
  should_include "$repo_name" || continue

  echo "workspace-install: repo=$repo_name"
  install_args=(--kit-repo "$KIT_REPO" --kit-ref "$KIT_REF")
  [ -n "$PROJECT" ] && install_args+=(--project "$PROJECT")
  install_args+=("${SETUP_ARGS[@]}")
  $NO_RUN && install_args+=(--no-run)
  $FORCE && install_args+=(--force)
  (cd "$d" && "$installer" "${install_args[@]}")
done

if $WRITE_RUNNER; then
  runner="$WORKSPACE_ROOT/workspace-ai.sh"
  if [ -f "$runner" ] && ! $FORCE; then
    echo "workspace-install: runner exists (skip): $runner"
  else
    cat > "$runner" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Workspace runner: bootstrap + setup + sync across repos that have ai-kit.lock.
#
# Usage (from workspace root):
#   ./workspace-ai.sh --all --codex
#   ./workspace-ai.sh --repos dispersion,pagos --claude
#   ./workspace-ai.sh --all --setup-all
#   ./workspace-ai.sh --init-agents --project smartpay --codex

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

repos_filter="__ALL__"
SETUP_ARGS=()
NO_SETUP=false
INIT_AGENTS=false
PROJECT=""

show_help() {
  echo "Usage:"
  echo "  $0 --all|--repos <a,b,c> [--codex|--claude|--gemini|--copilot|--setup-all|--no-setup]"
  echo "  $0 --init-agents [--project <asulado|smartpay>] [--codex|--claude|--gemini|--copilot|--setup-all|--no-setup]"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --all) repos_filter="__ALL__"; shift ;;
    --repos) repos_filter="$2"; shift 2 ;;
    --init-agents) INIT_AGENTS=true; shift ;;
    --project) PROJECT="$2"; shift 2 ;;
    --setup-all) SETUP_ARGS=(--all); shift ;;
    --no-setup) NO_SETUP=true; shift ;;
    --claude) SETUP_ARGS+=("--claude"); shift ;;
    --gemini) SETUP_ARGS+=("--gemini"); shift ;;
    --codex) SETUP_ARGS+=("--codex"); shift ;;
    --copilot) SETUP_ARGS+=("--copilot"); shift ;;
    --help|-h) show_help; exit 0 ;;
    *)
      echo "Unknown option: $1" 1>&2
      show_help
      exit 1
      ;;
  esac
done

should_include_repo() {
  local repo_name="$1"
  if [ "$repos_filter" = "__ALL__" ]; then
    return 0
  fi
  local IFS=','
  for r in $repos_filter; do
    [ "$r" = "$repo_name" ] && return 0
  done
  return 1
}

default_setup_args() {
  if $NO_SETUP; then
    return 0
  fi
  if [ ${#SETUP_ARGS[@]} -eq 0 ]; then
    SETUP_ARGS=(--codex)
  fi
}

default_setup_args

infer_project_from_any_repo() {
  [ -n "$PROJECT" ] && return 0
  lockfile="$(find "$WORKSPACE_ROOT" -maxdepth 3 -name ai-kit.lock -print -quit 2>/dev/null || true)"
  if [ -n "${lockfile:-}" ] && [ -f "$lockfile" ]; then
    PROJECT="$(sed -n 's/^AI_SKILLS_PROJECT=//p' "$lockfile" | head -n 1 || true)"
  fi
  [ -z "$PROJECT" ] && PROJECT="asulado"
}

bootstrap_workspace_kit() {
  local kit_repo_default="https://github.com/manuelcelyng/prueba-skills-codex.git"
  local kit_ref_default="main"
  local kit_repo="$kit_repo_default"
  local kit_ref="$kit_ref_default"

  lockfile="$(find "$WORKSPACE_ROOT" -maxdepth 3 -name ai-kit.lock -print -quit 2>/dev/null || true)"
  if [ -n "${lockfile:-}" ] && [ -f "$lockfile" ]; then
    v="$(sed -n 's/^AI_KIT_REPO=//p' "$lockfile" | head -n 1 || true)"
    [ -n "$v" ] && kit_repo="$v"
    v="$(sed -n 's/^AI_KIT_REF=//p' "$lockfile" | head -n 1 || true)"
    [ -n "$v" ] && kit_ref="$v"
  fi

  if [ -d "$WORKSPACE_ROOT/.ai-kit/.git" ]; then
    git -C "$WORKSPACE_ROOT/.ai-kit" remote set-url origin "$kit_repo" >/dev/null 2>&1 || true
  else
    rm -rf "$WORKSPACE_ROOT/.ai-kit"
    git clone "$kit_repo" "$WORKSPACE_ROOT/.ai-kit" >/dev/null
  fi

  git -C "$WORKSPACE_ROOT/.ai-kit" fetch --all --tags >/dev/null 2>&1 || true
  git -C "$WORKSPACE_ROOT/.ai-kit" checkout -q "$kit_ref"
  git -C "$WORKSPACE_ROOT/.ai-kit" pull --ff-only origin "$kit_ref" >/dev/null 2>&1 || true
}

init_workspace_agents() {
  infer_project_from_any_repo
  bootstrap_workspace_kit

  echo "Workspace: init AGENTS.md (project=$PROJECT)"

  export REPO_ROOT="$WORKSPACE_ROOT"
  export AI_SKILLS_PROJECT="$PROJECT"
  export AI_SKILLS_WORKSPACE=true

  "$WORKSPACE_ROOT/.ai-kit/tools/build-skills.sh" >/dev/null
  if ! $NO_SETUP; then
    "$WORKSPACE_ROOT/.ai-kit/tools/setup.sh" "${SETUP_ARGS[@]}"
  fi
  "$WORKSPACE_ROOT/.ai-kit/tools/init-workspace-agents.sh" --project "$PROJECT" >/dev/null
  "$WORKSPACE_ROOT/.ai-kit/tools/sync.sh" >/dev/null

  echo "OK: $WORKSPACE_ROOT/AGENTS.md"
}

if $INIT_AGENTS; then
  default_setup_args
  init_workspace_agents
  exit 0
fi

find "$WORKSPACE_ROOT" -maxdepth 3 -name ai-kit.lock -print 2>/dev/null | LC_ALL=C sort | while IFS= read -r lockfile; do
  repo_root="$(cd "$(dirname "$lockfile")" && pwd)"
  repo_name="$(basename "$repo_root")"

  should_include_repo "$repo_name" || continue

  if [ ! -x "$repo_root/scripts/ai/bootstrap.sh" ]; then
    echo "Skipping (no scripts): $repo_root" 1>&2
    continue
  fi

  echo "Repo: $repo_root"
  (cd "$repo_root" && ./scripts/ai/bootstrap.sh)
  if [ ! -f "$repo_root/AGENTS.md" ] && [ -x "$repo_root/scripts/ai/init-agents.sh" ]; then
    (cd "$repo_root" && ./scripts/ai/init-agents.sh "${SETUP_ARGS[@]}") >/dev/null 2>&1 || true
  fi
  if ! $NO_SETUP; then
    (cd "$repo_root" && ./scripts/ai/setup.sh "${SETUP_ARGS[@]}")
  fi
  (cd "$repo_root" && ./scripts/ai/sync.sh)
  echo "OK"
  echo ""
done
EOF
    chmod +x "$runner"
    echo "workspace-install: wrote runner $runner"
  fi
fi

echo "workspace-install: done"
