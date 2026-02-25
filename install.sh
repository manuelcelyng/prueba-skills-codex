#!/usr/bin/env bash
# AI Kit installer (service repo).
#
# Intended usage (run inside a service repo root):
#   curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/install.sh | bash
#
# Options:
#   --kit-repo <git-url>   Override AI_KIT_REPO
#   --kit-ref <ref>        Override AI_KIT_REF (default: main)
#   --project <name>       Skill projection profile (default: smartpay)
#   --all/--claude/...     Pass-through flags for ./scripts/ai/setup.sh
#   --no-run               Only install files; don't bootstrap/setup/sync
#   --no-setup             Skip setup (symlinks/copies) step
#   --force                Overwrite existing files
#
# Notes:
# - This installer creates: ai-kit.lock, scripts/ai/*, updates .gitignore, creates an AGENTS.md stub if missing.
# - Requires: git, bash, and network access.

set -euo pipefail

KIT_REPO_DEFAULT="https://github.com/manuelcelyng/prueba-skills-codex.git"
KIT_REF_DEFAULT="main"

KIT_REPO="$KIT_REPO_DEFAULT"
KIT_REF="$KIT_REF_DEFAULT"
PROJECT="smartpay"
NO_RUN=false
NO_SETUP=false
FORCE=false
SETUP_ARGS=()
SETUP_ARGS_FINAL=()

usage() {
  cat <<EOF
Usage: install.sh [--kit-repo <git-url>] [--kit-ref <ref>] [--project <name>] [--no-run] [--force]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kit-repo)
      [ $# -ge 2 ] || { echo "install: --kit-repo requires a value" >&2; exit 1; }
      KIT_REPO="$2"; shift 2 ;;
    --kit-ref)
      [ $# -ge 2 ] || { echo "install: --kit-ref requires a value" >&2; exit 1; }
      KIT_REF="$2"; shift 2 ;;
    --project)
      [ $# -ge 2 ] || { echo "install: --project requires a value" >&2; exit 1; }
      PROJECT="$2"; shift 2 ;;
    --all|--claude|--gemini|--codex|--copilot)
      SETUP_ARGS+=("$1"); shift ;;
    --no-run) NO_RUN=true; shift ;;
    --no-setup) NO_SETUP=true; shift ;;
    --force) FORCE=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

REPO_ROOT="$(pwd)"

if [ ! -d "$REPO_ROOT/.git" ]; then
  echo "install: expected to run in a git repo root (missing .git in $REPO_ROOT)" >&2
  exit 1
fi

write_file() {
  local path="$1"
  shift
  if [ -f "$path" ] && ! $FORCE; then
    echo "install: skip (exists): $path"
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  cat > "$path" <<EOF
$*
EOF
  echo "install: wrote $path"
}

append_gitignore_block() {
  local path="$1"
  local marker_begin="# AI KIT (BEGIN)"
  local marker_end="# AI KIT (END)"

  if [ ! -f "$path" ]; then
    touch "$path"
  fi

  if grep -qF "$marker_begin" "$path" 2>/dev/null; then
    echo "install: .gitignore already contains AI kit block"
    return 0
  fi

  cat >> "$path" <<'EOF'

# AI KIT (BEGIN)
.ai-kit/
.ai/
.claude/skills
.gemini/skills
.codex/skills
CLAUDE.md
GEMINI.md
.github/copilot-instructions.md
# AI KIT (END)
EOF
  echo "install: updated $path"
}

write_file "$REPO_ROOT/ai-kit.lock" \
"AI_KIT_REPO=$KIT_REPO
AI_KIT_REF=$KIT_REF
$( [ -n "$PROJECT" ] && echo "AI_SKILLS_PROJECT=$PROJECT" )"

write_file "$REPO_ROOT/scripts/ai/bootstrap.sh" \
'#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOCK_FILE="$REPO_ROOT/ai-kit.lock"

if [ ! -f "$LOCK_FILE" ]; then
  echo "bootstrap: missing ai-kit.lock at $LOCK_FILE" 1>&2
  exit 1
fi

# shellcheck disable=SC1090
source "$LOCK_FILE"

if [ -z "${AI_KIT_REPO:-}" ]; then
  echo "bootstrap: AI_KIT_REPO is required in ai-kit.lock" 1>&2
  exit 1
fi

AI_KIT_REF="${AI_KIT_REF:-main}"
AI_KIT_MODE="${AI_KIT_MODE:-git}"

src="$AI_KIT_REPO"
if [[ "$src" != /* ]] && [[ "$src" != *"://"* ]] && [[ "$src" != *@*:* ]]; then
  src="$(cd "$REPO_ROOT" && cd "$src" && pwd)"
fi

dest="$REPO_ROOT/.ai-kit"

# If a previous pilot used a symlink, replace it with a real clone.
if [ -L "$dest" ]; then
  rm -rf "$dest"
fi

if [ "$AI_KIT_MODE" = "workdir" ]; then
  if [[ "$src" == *"://"* ]] || [[ "$src" == *@*:* ]]; then
    echo "bootstrap: AI_KIT_MODE=workdir requires a local path (got $src)" 1>&2
    exit 1
  fi
  if [ ! -d "$src" ]; then
    echo "bootstrap: AI_KIT_REPO path not found: $src" 1>&2
    exit 1
  fi
  rm -rf "$dest"
  ln -s "$src" "$dest"
  echo "bootstrap: .ai-kit linked -> $src"
  exit 0
fi

if [ -d "$dest/.git" ]; then
  git -C "$dest" remote set-url origin "$src" >/dev/null 2>&1 || true
else
  rm -rf "$dest"
  git clone "$src" "$dest" >/dev/null
fi

git -C "$dest" fetch --all --tags >/dev/null 2>&1 || true
git -C "$dest" checkout -q "$AI_KIT_REF"
git -C "$dest" pull --ff-only origin "$AI_KIT_REF" >/dev/null 2>&1 || true

echo "bootstrap: .ai-kit ready ($AI_KIT_REF)"'

write_file "$REPO_ROOT/scripts/ai/setup.sh" \
'#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

"$REPO_ROOT/scripts/ai/bootstrap.sh"

args=("$@")

# If no args and AGENTS.md is missing, choose flags once so the stub matches the selection.
if [ ${#args[@]} -eq 0 ] && [ ! -f "$REPO_ROOT/AGENTS.md" ]; then
  flags_line="--codex"
  if [ -t 0 ] || exec 3<>/dev/tty 2>/dev/null; then
    exec 3<&- 2>/dev/null || true
    exec 3>&- 2>/dev/null || true
    tmp_flags="$(mktemp)"
    "$REPO_ROOT/.ai-kit/tools/setup.sh" --choose-flags | tee "$tmp_flags"
    flags_line="$(sed -n "s/^AI_KIT_FLAGS: //p" "$tmp_flags" | head -n 1)"
    rm -f "$tmp_flags"
    [ -z "$flags_line" ] && flags_line="--codex"
  fi
  # shellcheck disable=SC2206
  args=($flags_line)
  "$REPO_ROOT/scripts/ai/init-agents.sh" "${args[@]}" >/dev/null 2>&1 || true
elif [ ! -f "$REPO_ROOT/AGENTS.md" ]; then
  "$REPO_ROOT/scripts/ai/init-agents.sh" "${args[@]}" >/dev/null 2>&1 || true
fi

(cd "$REPO_ROOT" && "$REPO_ROOT/.ai-kit/tools/build-skills.sh")
(cd "$REPO_ROOT" && "$REPO_ROOT/.ai-kit/tools/setup.sh" "${args[@]}")'

write_file "$REPO_ROOT/scripts/ai/sync.sh" \
'#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

"$REPO_ROOT/scripts/ai/bootstrap.sh"

if [ ! -f "$REPO_ROOT/AGENTS.md" ]; then
  "$REPO_ROOT/scripts/ai/init-agents.sh" >/dev/null 2>&1 || true
fi

(cd "$REPO_ROOT" && "$REPO_ROOT/.ai-kit/tools/build-skills.sh")
(cd "$REPO_ROOT" && "$REPO_ROOT/.ai-kit/tools/sync.sh" "$@")'

write_file "$REPO_ROOT/scripts/ai/create-skill.sh" \
'#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

"$REPO_ROOT/scripts/ai/bootstrap.sh" >/dev/null
exec "$REPO_ROOT/.ai-kit/tools/create-skill.sh" --where "$REPO_ROOT/skills" "$@"'

write_file "$REPO_ROOT/scripts/ai/init-agents.sh" \
'#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

"$REPO_ROOT/scripts/ai/bootstrap.sh" >/dev/null
exec "$REPO_ROOT/.ai-kit/tools/init-agents.sh" "$@"'

chmod +x \
  "$REPO_ROOT/scripts/ai/bootstrap.sh" \
  "$REPO_ROOT/scripts/ai/setup.sh" \
  "$REPO_ROOT/scripts/ai/sync.sh" \
  "$REPO_ROOT/scripts/ai/create-skill.sh" \
  "$REPO_ROOT/scripts/ai/init-agents.sh"

append_gitignore_block "$REPO_ROOT/.gitignore"

if $NO_RUN; then
  echo "install: done (--no-run)"
  exit 0
fi

  echo "install: running bootstrap/setup/sync"
"$REPO_ROOT/scripts/ai/bootstrap.sh"

choose_setup_args() {
  if [ ${#SETUP_ARGS[@]} -gt 0 ]; then
    SETUP_ARGS_FINAL=("${SETUP_ARGS[@]}")
    return 0
  fi

  # If setup is skipped, avoid prompting; keep a deterministic default for stub commands.
  if $NO_SETUP; then
    SETUP_ARGS_FINAL=(--codex)
    return 0
  fi

  # Prompt if we can actually read AND write user input:
  # - stdin is a TTY (script executed from a file), OR
  # - /dev/tty is usable (curl | bash).
  flags_line="--codex"
  can_prompt=false
  if [ -t 0 ]; then
    can_prompt=true
  elif exec 3<>/dev/tty 2>/dev/null; then
    exec 3<&-
    exec 3>&-
    can_prompt=true
  fi

  if [ "$can_prompt" = true ]; then
    echo "install: choose assistants (Enter = Codex default)..."
    tmp_flags="$(mktemp)"
    # Show menu output to the user while capturing it for parsing.
    "$REPO_ROOT/.ai-kit/tools/setup.sh" --choose-flags | tee "$tmp_flags"
    flags_line="$(sed -n "s/^AI_KIT_FLAGS: //p" "$tmp_flags" | head -n 1)"
    rm -f "$tmp_flags"
    [ -z "$flags_line" ] && flags_line="--codex"
  else
    echo "install: non-interactive (no TTY). Defaulting to --codex." 1>&2
    echo "install: to choose interactively, run:" 1>&2
    echo "  curl -fsSLO https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/install.sh && bash install.sh" 1>&2
  fi

  # Parse flags line into array
  # shellcheck disable=SC2206
  SETUP_ARGS_FINAL=($flags_line)
  if [ ${#SETUP_ARGS_FINAL[@]} -eq 0 ]; then
    SETUP_ARGS_FINAL=(--codex)
  fi
}

choose_setup_args

if [ ! -f "$REPO_ROOT/AGENTS.md" ]; then
  "$REPO_ROOT/scripts/ai/init-agents.sh" "${SETUP_ARGS_FINAL[@]}" >/dev/null 2>&1 || true
fi

if ! $NO_SETUP; then
  "$REPO_ROOT/scripts/ai/setup.sh" "${SETUP_ARGS_FINAL[@]}"
fi

"$REPO_ROOT/scripts/ai/sync.sh"

echo "install: done"
