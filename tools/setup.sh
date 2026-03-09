#!/usr/bin/env bash
# Setup AI skills for a single repo (Codex / Claude / Gemini / Copilot)
#
# This follows the Prowler-style projection:
# - .claude/skills -> .ai/skills (symlink)
# - .gemini/skills -> .ai/skills (symlink)
# - .codex/skills  -> .ai/skills (symlink)
# - AGENTS.md -> CLAUDE.md / GEMINI.md (copies next to each AGENTS.md found)
# - AGENTS.md -> .github/copilot-instructions.md (copy)
# - assistant-specific SDD overlays appended automatically where applicable
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
OVERLAYS_DIR="$REPO_ROOT/.ai-kit/references/sdd/assistant-overlays"

RED='[0;31m'
GREEN='[0;32m'
YELLOW='[1;33m'
BLUE='[0;34m'
CYAN='[0;36m'
BOLD='[1m'
NC='[0m'

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

setup_codex_mcp_azuredevops() {
  local codex_home="${CODEX_HOME:-$HOME/.codex}"
  local codex_config="$codex_home/config.toml"

  local server_path=""
  if [ -f "$REPO_ROOT/.ai-kit/mcp/azuredevops/server.js" ]; then
    server_path="$REPO_ROOT/.ai-kit/mcp/azuredevops/server.js"
  elif [ -f "$REPO_ROOT/mcp/azuredevops/server.js" ]; then
    server_path="$REPO_ROOT/mcp/azuredevops/server.js"
  else
    echo -e "${YELLOW}Codex MCP(azuredevops): server.js not found. Skipping.${NC}"
    return 0
  fi

  if ! command -v node >/dev/null 2>&1; then
    echo -e "${YELLOW}Codex MCP(azuredevops): node not found. Skipping.${NC}"
    return 0
  fi
  if ! command -v npm >/dev/null 2>&1; then
    echo -e "${YELLOW}Codex MCP(azuredevops): npm not found. Skipping dependency install.${NC}"
  else
    local pkg_dir
    pkg_dir="$(cd "$(dirname "$server_path")" && pwd)"
    if [ ! -d "$pkg_dir/node_modules" ]; then
      echo -e "${BLUE}Codex MCP(azuredevops): installing npm deps...${NC}"
      npm --prefix "$pkg_dir" install --silent || {
        echo -e "${YELLOW}Codex MCP(azuredevops): npm install failed (continuing).${NC}"
      }
    fi
  fi

  mkdir -p "$codex_home"
  if [ ! -f "$codex_config" ]; then
    touch "$codex_config"
  fi

  python3 - "$codex_config" "$server_path" <<'PYCONF'
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
server_path = sys.argv[2]
lines = config_path.read_text(encoding="utf-8", errors="replace").splitlines(True)
header = "[mcp_servers.azuredevops]\\n"
command_line = 'command = "node"\\n'
args_line = f'args = ["{server_path}"]\\n'

def is_section_start(line: str) -> bool:
    return line.startswith("[") and line.rstrip().endswith("]")

out = []
i = 0
found = False
while i < len(lines):
    line = lines[i]
    if line.strip() == "[mcp_servers.azuredevops]":
        found = True
        out.append(header)
        i += 1
        has_command = False
        has_args = False
        while i < len(lines) and not is_section_start(lines[i].lstrip()):
            cur = lines[i]
            if cur.strip().startswith("command"):
                if not has_command:
                    out.append(command_line)
                    has_command = True
                i += 1
                continue
            if cur.strip().startswith("args"):
                if not has_args:
                    out.append(args_line)
                    has_args = True
                i += 1
                continue
            out.append(cur)
            i += 1
        if not has_command:
            out.append(command_line)
        if not has_args:
            out.append(args_line)
        continue
    out.append(line)
    i += 1

if not found:
    if out and not out[-1].endswith("\\n"):
        out[-1] = out[-1] + "\\n"
    if out and out[-1].strip() != "":
        out.append("\\n")
    out.append(header)
    out.append(command_line)
    out.append(args_line)

config_path.write_text("".join(out), encoding="utf-8")
print(str(config_path))
PYCONF

  echo -e "${GREEN}Codex MCP(azuredevops): configured in $codex_config${NC}"
}

show_menu() {
  echo -e "${BOLD}Which AI assistants do you use?${NC}"
  echo -e "${CYAN}(Press Enter with no selection to default to Codex only)${NC}"
  echo ""
  echo "  1) Claude Code"
  echo "  2) Gemini CLI"
  echo "  3) Codex (OpenAI)"
  echo "  4) GitHub Copilot"
  echo "  a) All"
  echo "  n) None"
  echo ""
  echo -n "Select (e.g. 1 3 4) or 'a' or 'n': "

  choice=""
  if ! read -r choice < /dev/tty 2>/dev/null; then
    if [ -t 0 ]; then
      read -r choice || choice=""
    else
      choice=""
    fi
  fi

  case "$choice" in
    "") SETUP_CODEX=true ;;
    a|A)
      SETUP_CLAUDE=true
      SETUP_GEMINI=true
      SETUP_CODEX=true
      SETUP_COPILOT=true
      ;;
    n|N) ;;
    *)
      for c in $choice; do
        case "$c" in
          1) SETUP_CLAUDE=true ;;
          2) SETUP_GEMINI=true ;;
          3) SETUP_CODEX=true ;;
          4) SETUP_COPILOT=true ;;
        esac
      done
      ;;
  esac
}

normalized_flags_line() {
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

print_engram_hint() {
  echo -e "${CYAN}Optional Engram setup for persistent memory:${NC}"
  $SETUP_CODEX && echo -e "  - Codex: ${BOLD}engram setup codex${NC}"
  $SETUP_GEMINI && echo -e "  - Gemini CLI: ${BOLD}engram setup gemini-cli${NC}"
  $SETUP_CLAUDE && echo -e "  - Claude Code: ${BOLD}engram setup claude-code${NC}"
  if $SETUP_COPILOT; then
    echo -e "  - Copilot/VS Code: add Engram MCP per the official README${NC}"
  fi
}

post_setup() {
  if $SETUP_CODEX; then
    setup_codex_mcp_azuredevops
  fi
  echo ""
  print_engram_hint
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

append_overlay() {
  local output_file="$1"
  local overlay_key="$2"
  local overlay_file="$OVERLAYS_DIR/$overlay_key.md"

  [ -f "$overlay_file" ] || return 0

  printf '

<!-- AI-KIT SDD OVERLAY (%s) -->

' "$overlay_key" >> "$output_file"
  cat "$overlay_file" >> "$output_file"
}

copy_agents_md() {
  local target_name="$1"
  local overlay_key="$2"
  local count=0

  local agents_files
  agents_files=$(find "$REPO_ROOT" -name "AGENTS.md"     -not -path "*/.git/*"     -not -path "*/.ai-kit/*"     -not -path "*/.ai/*"     -not -path "*/node_modules/*" 2>/dev/null)

  for agents_file in $agents_files; do
    local agents_dir
    local target_file
    agents_dir=$(dirname "$agents_file")
    target_file="$agents_dir/$target_name"
    cp "$agents_file" "$target_file"
    append_overlay "$target_file" "$overlay_key"
    count=$((count + 1))
  done

  echo -e "${GREEN}  ✓ Copied $count AGENTS.md -> $target_name${NC}"
}

setup_claude() {
  symlink_dir "$REPO_ROOT/.claude" "$REPO_ROOT/.claude/skills"
  echo -e "${GREEN}  ✓ .claude/skills -> .ai/skills${NC}"
  copy_agents_md "CLAUDE.md" "claude"
}

setup_gemini() {
  symlink_dir "$REPO_ROOT/.gemini" "$REPO_ROOT/.gemini/skills"
  echo -e "${GREEN}  ✓ .gemini/skills -> .ai/skills${NC}"
  copy_agents_md "GEMINI.md" "gemini"
}

setup_codex() {
  symlink_dir "$REPO_ROOT/.codex" "$REPO_ROOT/.codex/skills"
  echo -e "${GREEN}  ✓ .codex/skills -> .ai/skills${NC}"
  echo -e "${GREEN}  ✓ Codex uses AGENTS.md natively${NC}"
  if [ -f "$OVERLAYS_DIR/codex.md" ]; then
    echo -e "${CYAN}  ↳ Codex SDD quick start: $OVERLAYS_DIR/codex.md${NC}"
  fi
}

setup_copilot() {
  if [ -f "$REPO_ROOT/AGENTS.md" ]; then
    mkdir -p "$REPO_ROOT/.github"
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.github/copilot-instructions.md"
    append_overlay "$REPO_ROOT/.github/copilot-instructions.md" "copilot"
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
  if ! $SETUP_CLAUDE && ! $SETUP_GEMINI && ! $SETUP_CODEX && ! $SETUP_COPILOT; then
    show_menu
  fi
  echo ""
  echo "AI_KIT_FLAGS: $(normalized_flags_line)"
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
post_setup

echo ""
echo -e "${GREEN}Done.${NC}"
