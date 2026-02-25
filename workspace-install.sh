#!/usr/bin/env bash
# AI Kit installer (workspace).
#
# Intended usage (run in a folder that contains multiple repos):
#   curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/workspace-install.sh | bash
#
# Options:
#   --kit-repo <git-url>   Override AI_KIT_REPO
#   --kit-ref <ref>        Override AI_KIT_REF (default: main)
#   --repos a,b,c          Only install into these repo folder names
#   --setup-all            Configure all assistants (default)
#   --setup-interactive    Prompt once and apply to all repos
#   --setup-none           Skip setup step for all repos
#   --no-run               Only install files; don't run bootstrap/setup/sync
#   --force                Overwrite existing files

set -euo pipefail

KIT_REPO_DEFAULT="https://github.com/manuelcelyng/prueba-skills-codex.git"
KIT_REF_DEFAULT="main"

KIT_REPO="$KIT_REPO_DEFAULT"
KIT_REF="$KIT_REF_DEFAULT"
REPOS_FILTER=""
NO_RUN=false
FORCE=false
SETUP_MODE="all"
SETUP_ARGS=()

usage() {
  cat <<EOF
Usage: workspace-install.sh [--kit-repo <git-url>] [--kit-ref <ref>] [--repos a,b,c] [--no-run] [--force]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kit-repo) KIT_REPO="$2"; shift 2 ;;
    --kit-ref) KIT_REF="$2"; shift 2 ;;
    --repos) REPOS_FILTER="$2"; shift 2 ;;
    --setup-all) SETUP_MODE="all"; shift ;;
    --setup-none) SETUP_MODE="none"; shift ;;
    --setup-interactive) SETUP_MODE="interactive"; shift ;;
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

installer="$tmpdir/install.sh"
curl -fsSL "https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/${KIT_REF}/install.sh" -o "$installer"
chmod +x "$installer"

if [ "$SETUP_MODE" = "none" ]; then
  SETUP_ARGS+=(--no-setup)
elif [ "$SETUP_MODE" = "all" ]; then
  SETUP_ARGS+=(--all)
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
    if exec 3</dev/tty 2>/dev/null; then
      read -r -u 3 choice || choice="a"
      exec 3<&-
    else
      choice="a"
    fi
    case "$choice" in
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
    SETUP_ARGS+=(--all)
  fi
fi

for d in "$WORKSPACE_ROOT"/*; do
  [ -d "$d" ] || continue
  [ -d "$d/.git" ] || continue
  repo_name="$(basename "$d")"
  should_include "$repo_name" || continue

  echo "workspace-install: repo=$repo_name"
  (cd "$d" && "$installer" --kit-repo "$KIT_REPO" --kit-ref "$KIT_REF" "${SETUP_ARGS[@]}" $( $NO_RUN && echo "--no-run" ) $( $FORCE && echo "--force" ))
done

echo "workspace-install: done"
