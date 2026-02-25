#!/usr/bin/env bash
set -euo pipefail

# Run bootstrap + setup + sync across multiple repos in a workspace.
#
# Usage (from workspace root):
#   ./workspace-ai.sh --all --codex
#   ./workspace-ai.sh --repos dispersion,novedades --claude
#   ./workspace-ai.sh --all --setup-all

WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(pwd)}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

repos_filter=""
SETUP_ARGS=()
NO_SETUP=false

show_help() {
  echo "Usage:"
  echo "  $0 --all|--repos <a,b,c> [--codex|--claude|--gemini|--copilot|--setup-all|--no-setup]"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --all) repos_filter="__ALL__"; shift ;;
    --repos) repos_filter="$2"; shift 2 ;;
    --setup-all) SETUP_ARGS=(--all); shift ;;
    --no-setup) NO_SETUP=true; shift ;;
    --claude) SETUP_ARGS+=("--claude"); shift ;;
    --gemini) SETUP_ARGS+=("--gemini"); shift ;;
    --codex) SETUP_ARGS+=("--codex"); shift ;;
    --copilot) SETUP_ARGS+=("--copilot"); shift ;;
    --help|-h) show_help; exit 0 ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      show_help
      exit 1
      ;;
  esac
done

if [ -z "$repos_filter" ]; then
  repos_filter="__ALL__"
fi

default_setup_args() {
  if $NO_SETUP; then
    return 0
  fi
  if [ ${#SETUP_ARGS[@]} -eq 0 ]; then
    SETUP_ARGS=(--codex)
  fi
}

default_setup_args

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

echo -e "${BLUE}Workspace AI setup${NC}"
echo "=================="
echo ""

find "$WORKSPACE_ROOT" -maxdepth 3 -name ai-kit.lock -print 2>/dev/null | LC_ALL=C sort | while IFS= read -r lockfile; do
  repo_root="$(cd "$(dirname "$lockfile")" && pwd)"
  repo_name="$(basename "$repo_root")"

  should_include_repo "$repo_name" || continue

  if [ ! -x "$repo_root/scripts/ai/bootstrap.sh" ]; then
    echo -e "${YELLOW}Skipping (no scripts): $repo_root${NC}"
    continue
  fi

  echo -e "${BLUE}Repo: $repo_root${NC}"
  (cd "$repo_root" && ./scripts/ai/bootstrap.sh)
  if [ ! -f "$repo_root/AGENTS.md" ] && [ -x "$repo_root/scripts/ai/init-agents.sh" ]; then
    (cd "$repo_root" && ./scripts/ai/init-agents.sh "${SETUP_ARGS[@]}") >/dev/null 2>&1 || true
  fi
  if ! $NO_SETUP; then
    (cd "$repo_root" && ./scripts/ai/setup.sh "${SETUP_ARGS[@]}")
  fi
  (cd "$repo_root" && ./scripts/ai/sync.sh)
  echo -e "${GREEN}OK${NC}"
  echo ""
done

echo -e "${GREEN}Done.${NC}"
