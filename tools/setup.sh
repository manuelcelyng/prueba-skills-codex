#!/usr/bin/env bash
# Setup AI skills for a single repo (Codex / Claude / Gemini / Copilot)
#
# This follows the Prowler-style projection:
# - .claude/skills -> .ai/skills (symlink)
# - .gemini/skills -> .ai/skills (symlink)
# - .codex/skills  -> .ai/skills (symlink)
# - AGENTS.md -> CLAUDE.md / GEMINI.md (copies next to each AGENTS.md found)
# - AGENTS.md -> .github/copilot-instructions.md (copy)
#
# Usage:
#   .ai-kit/tools/setup.sh              # Interactive mode
#   .ai-kit/tools/setup.sh --all        # Configure all
#   .ai-kit/tools/setup.sh --claude     # Only Claude
#   .ai-kit/tools/setup.sh --help

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
SKILLS_SOURCE="$REPO_ROOT/.ai/skills"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_CODEX=false
SETUP_COPILOT=false
CHOOSE_FLAGS=false

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --all       Configure all AI assistants"
  echo "  --claude    Configure Claude Code"
  echo "  --gemini    Configure Gemini CLI"
  echo "  --codex     Configure Codex (OpenAI)"
  echo "  --copilot   Configure GitHub Copilot"
  echo "  --choose-flags  Interactive selection; prints flags and exits"
  echo "  --help|-h   Show help"
}

ensure_skills_source() {
  if [ ! -d "$SKILLS_SOURCE" ]; then
    echo -e "${YELLOW}Missing .ai/skills. Building skills...${NC}"
    "$REPO_ROOT/.ai-kit/tools/build-skills.sh"
  fi
  if [ ! -d "$SKILLS_SOURCE" ]; then
    echo -e "${RED}Missing skills source: $SKILLS_SOURCE${NC}"
    exit 1
  fi
}

show_menu() {
  echo -e "${BOLD}Which AI assistants do you use?${NC}"
  echo -e "${CYAN}(Use numbers to toggle, Enter to confirm)${NC}"
  echo -e "${CYAN}(If you press Enter immediately, it defaults to Codex only)${NC}"
  echo ""

  local options=("Claude Code" "Gemini CLI" "Codex (OpenAI)" "GitHub Copilot")
  local selected=(false false false false)
  local touched=false

  while true; do
    for i in "${!options[@]}"; do
      if [ "${selected[$i]}" = true ]; then
        echo -e "  ${GREEN}[x]${NC} $((i+1)). ${options[$i]}"
      else
        echo -e "  [ ] $((i+1)). ${options[$i]}"
      fi
    done
    echo ""
    echo -e "  ${YELLOW}a${NC}. Select all"
    echo -e "  ${YELLOW}n${NC}. Select none"
    echo ""
    echo -n "Toggle (1-4, a, n) or Enter to confirm: "
    choice=""
    # Prefer /dev/tty so this works even when stdin is piped (curl | bash).
    # If /dev/tty isn't available (no controlling terminal), fall back to stdin.
    if ! read -r choice < /dev/tty 2>/dev/null; then
      read -r choice || choice=""
    fi

    case $choice in
      1) touched=true; selected[0]=$([ "${selected[0]}" = true ] && echo false || echo true) ;;
      2) touched=true; selected[1]=$([ "${selected[1]}" = true ] && echo false || echo true) ;;
      3) touched=true; selected[2]=$([ "${selected[2]}" = true ] && echo false || echo true) ;;
      4) touched=true; selected[3]=$([ "${selected[3]}" = true ] && echo false || echo true) ;;
      a|A) touched=true; selected=(true true true true) ;;
      n|N) touched=true; selected=(false false false false) ;;
      "")
        # Default behavior:
        # - If user didn't toggle anything and just pressed Enter, configure Codex only.
        # - If user toggled and ended up selecting none, keep none (no setup).
        if [ "$touched" = false ] && [ "${selected[0]}" = false ] && [ "${selected[1]}" = false ] && [ "${selected[2]}" = false ] && [ "${selected[3]}" = false ]; then
          selected=(false false true false)
        fi
        break
        ;;
      *) echo -e "${RED}Invalid option${NC}" ;;
    esac

    echo -en "\033[10A\033[J"
  done

  SETUP_CLAUDE=${selected[0]}
  SETUP_GEMINI=${selected[1]}
  SETUP_CODEX=${selected[2]}
  SETUP_COPILOT=${selected[3]}
}

normalized_flags_line() {
  # Default to Codex if nothing selected.
  if ! $SETUP_CLAUDE && ! $SETUP_GEMINI && ! $SETUP_CODEX && ! $SETUP_COPILOT; then
    echo "--codex"
    return 0
  fi

  if $SETUP_CLAUDE && $SETUP_GEMINI && $SETUP_CODEX && $SETUP_COPILOT; then
    echo "--all"
    return 0
  fi

  out=""
  $SETUP_CLAUDE && out="$out --claude"
  $SETUP_GEMINI && out="$out --gemini"
  $SETUP_CODEX && out="$out --codex"
  $SETUP_COPILOT && out="$out --copilot"
  echo "$out" | sed 's/^[[:space:]]*//'
}

symlink_dir() {
  local target_dir="$1"
  local link_path="$2"

  mkdir -p "$target_dir"

  if [ -L "$link_path" ]; then
    rm "$link_path"
  elif [ -d "$link_path" ]; then
    mv "$link_path" "${link_path}.backup.$(date +%s)"
  fi

  ln -s "$SKILLS_SOURCE" "$link_path"
}

copy_agents_md() {
  local target_name="$1"
  local count=0

  # Avoid copying from generated/vendor dirs
  local agents_files
  agents_files=$(find "$REPO_ROOT" -name "AGENTS.md" \
    -not -path "*/.git/*" \
    -not -path "*/.ai-kit/*" \
    -not -path "*/.ai/*" \
    -not -path "*/node_modules/*" 2>/dev/null)

  for agents_file in $agents_files; do
    local agents_dir
    agents_dir=$(dirname "$agents_file")
    cp "$agents_file" "$agents_dir/$target_name"
    count=$((count + 1))
  done

  echo -e "${GREEN}  ✓ Copied $count AGENTS.md -> $target_name${NC}"
}

setup_claude() {
  symlink_dir "$REPO_ROOT/.claude" "$REPO_ROOT/.claude/skills"
  echo -e "${GREEN}  ✓ .claude/skills -> .ai/skills${NC}"
  copy_agents_md "CLAUDE.md"
}

setup_gemini() {
  symlink_dir "$REPO_ROOT/.gemini" "$REPO_ROOT/.gemini/skills"
  echo -e "${GREEN}  ✓ .gemini/skills -> .ai/skills${NC}"
  copy_agents_md "GEMINI.md"
}

setup_codex() {
  symlink_dir "$REPO_ROOT/.codex" "$REPO_ROOT/.codex/skills"
  echo -e "${GREEN}  ✓ .codex/skills -> .ai/skills${NC}"
  echo -e "${GREEN}  ✓ Codex uses AGENTS.md natively${NC}"
}

setup_copilot() {
  if [ -f "$REPO_ROOT/AGENTS.md" ]; then
    mkdir -p "$REPO_ROOT/.github"
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.github/copilot-instructions.md"
    echo -e "${GREEN}  ✓ AGENTS.md -> .github/copilot-instructions.md${NC}"
  fi
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --all)
      SETUP_CLAUDE=true
      SETUP_GEMINI=true
      SETUP_CODEX=true
      SETUP_COPILOT=true
      shift
      ;;
    --choose-flags) CHOOSE_FLAGS=true; shift ;;
    --claude) SETUP_CLAUDE=true; shift ;;
    --gemini) SETUP_GEMINI=true; shift ;;
    --codex) SETUP_CODEX=true; shift ;;
    --copilot) SETUP_COPILOT=true; shift ;;
    --help|-h) show_help; exit 0 ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      show_help
      exit 1
      ;;
  esac
done

if $CHOOSE_FLAGS; then
  # Print flags to stdout (installer-friendly). Render the menu to stderr.
  if ! $SETUP_CLAUDE && ! $SETUP_GEMINI && ! $SETUP_CODEX && ! $SETUP_COPILOT; then
    show_menu 1>&2
  fi
  normalized_flags_line
  exit 0
fi

if ! $SETUP_CLAUDE && ! $SETUP_GEMINI && ! $SETUP_CODEX && ! $SETUP_COPILOT; then
  show_menu
fi

ensure_skills_source

echo -e "${BLUE}Setting up AI assistants...${NC}"
echo ""

$SETUP_CLAUDE && setup_claude
$SETUP_GEMINI && setup_gemini
$SETUP_CODEX && setup_codex
$SETUP_COPILOT && setup_copilot

echo ""
echo -e "${GREEN}Done.${NC}"
