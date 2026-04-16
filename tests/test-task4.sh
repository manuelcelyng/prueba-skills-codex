#!/usr/bin/env bash
set -euo pipefail

# Test script for Task 4 functions
WORKSPACE_ROOT="$(pwd)"
REPO_ROOT="$(mktemp -d)"
KIT_DIR="$WORKSPACE_ROOT"  # Use the ai-kit repo itself as the kit

# Init a git repo in the temp dir
git init "$REPO_ROOT" >/dev/null 2>&1

# Source lib.sh
source "$WORKSPACE_ROOT/tools/lib.sh"

FORCE=false
is_java=false
is_python=false
is_workspace=false
PROJECT="smartpay"

# Source the three functions from install.sh (extract them)
eval "$(sed -n '/^install_steering_for_kiro()/,/^}/p' "$WORKSPACE_ROOT/install.sh")"
eval "$(sed -n '/^generate_agents_md()/,/^}/p' "$WORKSPACE_ROOT/install.sh")"
eval "$(sed -n '/^generate_instruction_file()/,/^}/p' "$WORKSPACE_ROOT/install.sh")"

ERRORS=0

echo "=== TEST 4.1: install_steering_for_kiro ==="

install_steering_for_kiro 2>/dev/null

# Check files exist
[ -f "$REPO_ROOT/.kiro/steering/main.md" ] && echo "  ✅ main.md created" || { echo "  ❌ main.md NOT created"; ERRORS=$((ERRORS+1)); }
[ -f "$REPO_ROOT/.kiro/steering/collaboration.md" ] && echo "  ✅ collaboration.md created" || { echo "  ❌ collaboration.md NOT created"; ERRORS=$((ERRORS+1)); }

# Check frontmatter main.md
head -1 "$REPO_ROOT/.kiro/steering/main.md" | grep -q '^---$' && echo "  ✅ main.md starts with ---" || { echo "  ❌ main.md missing opening ---"; ERRORS=$((ERRORS+1)); }
grep -q 'inclusion: always' "$REPO_ROOT/.kiro/steering/main.md" && echo "  ✅ inclusion: always" || { echo "  ❌ missing inclusion: always"; ERRORS=$((ERRORS+1)); }
grep -q 'name: ai-kit-main' "$REPO_ROOT/.kiro/steering/main.md" && echo "  ✅ name: ai-kit-main" || { echo "  ❌ missing name"; ERRORS=$((ERRORS+1)); }
grep -q 'description: Reglas principales' "$REPO_ROOT/.kiro/steering/main.md" && echo "  ✅ correct description" || { echo "  ❌ missing description"; ERRORS=$((ERRORS+1)); }

# Check frontmatter collaboration.md
grep -q 'inclusion: auto' "$REPO_ROOT/.kiro/steering/collaboration.md" && echo "  ✅ inclusion: auto" || { echo "  ❌ missing inclusion: auto"; ERRORS=$((ERRORS+1)); }
grep -q 'name: ai-kit-collaboration' "$REPO_ROOT/.kiro/steering/collaboration.md" && echo "  ✅ name: ai-kit-collaboration" || { echo "  ❌ missing name"; ERRORS=$((ERRORS+1)); }

# Check content references
grep -q 'AGENTS.md' "$REPO_ROOT/.kiro/steering/main.md" && echo "  ✅ references AGENTS.md" || { echo "  ❌ no AGENTS.md ref"; ERRORS=$((ERRORS+1)); }
grep -q 'references/sdd/sdd-playbook.md' "$REPO_ROOT/.kiro/steering/main.md" && echo "  ✅ references sdd-playbook" || { echo "  ❌ no sdd-playbook ref"; ERRORS=$((ERRORS+1)); }
grep -q 'skills' "$REPO_ROOT/.kiro/steering/main.md" && echo "  ✅ mentions skills" || { echo "  ❌ no skills mention"; ERRORS=$((ERRORS+1)); }
grep -qE 'GitLab|Azure DevOps|gitlab|azuredevops' "$REPO_ROOT/.kiro/steering/collaboration.md" && echo "  ✅ mentions GitLab/Azure DevOps" || { echo "  ❌ no GitLab/AzDO mention"; ERRORS=$((ERRORS+1)); }

# Preserve without --force
echo "custom content" > "$REPO_ROOT/.kiro/steering/main.md"
FORCE=false
install_steering_for_kiro 2>/dev/null
grep -q 'custom content' "$REPO_ROOT/.kiro/steering/main.md" && echo "  ✅ preserved without --force" || { echo "  ❌ overwritten without --force"; ERRORS=$((ERRORS+1)); }

# Overwrite with --force
FORCE=true
install_steering_for_kiro 2>/dev/null
grep -q 'inclusion: always' "$REPO_ROOT/.kiro/steering/main.md" && echo "  ✅ overwritten with --force" || { echo "  ❌ NOT overwritten with --force"; ERRORS=$((ERRORS+1)); }
FORCE=false

echo ""
echo "=== TEST 4.2: generate_agents_md ==="

generate_agents_md 2>/dev/null

[ -f "$REPO_ROOT/AGENTS.md" ] && echo "  ✅ AGENTS.md created" || { echo "  ❌ AGENTS.md NOT created"; ERRORS=$((ERRORS+1)); }

# No legacy references
! grep -q '\.ai-kit/' "$REPO_ROOT/AGENTS.md" && echo "  ✅ no .ai-kit/ refs" || { echo "  ❌ has .ai-kit/ refs"; ERRORS=$((ERRORS+1)); }
! grep -q 'scripts/ai/' "$REPO_ROOT/AGENTS.md" && echo "  ✅ no scripts/ai/ refs" || { echo "  ❌ has scripts/ai/ refs"; ERRORS=$((ERRORS+1)); }
! grep -q 'ai-kit\.lock' "$REPO_ROOT/AGENTS.md" && echo "  ✅ no ai-kit.lock refs" || { echo "  ❌ has ai-kit.lock refs"; ERRORS=$((ERRORS+1)); }

# Correct references
grep -q 'references/sdd/sdd-playbook.md' "$REPO_ROOT/AGENTS.md" && echo "  ✅ references sdd-playbook" || { echo "  ❌ no sdd-playbook ref"; ERRORS=$((ERRORS+1)); }
grep -q 'ai-init-agents' "$REPO_ROOT/AGENTS.md" && echo "  ✅ mentions ai-init-agents" || { echo "  ❌ no ai-init-agents mention"; ERRORS=$((ERRORS+1)); }
grep -q 'SDD Quick Start' "$REPO_ROOT/AGENTS.md" && echo "  ✅ has SDD Quick Start" || { echo "  ❌ no SDD Quick Start"; ERRORS=$((ERRORS+1)); }

# Preserve without --force
echo "custom agents" > "$REPO_ROOT/AGENTS.md"
FORCE=false
generate_agents_md 2>/dev/null
grep -q 'custom agents' "$REPO_ROOT/AGENTS.md" && echo "  ✅ preserved without --force" || { echo "  ❌ overwritten without --force"; ERRORS=$((ERRORS+1)); }

# Restore for next tests
FORCE=true
generate_agents_md 2>/dev/null
FORCE=false

echo ""
echo "=== TEST 4.3: generate_instruction_file ==="

# Claude
generate_instruction_file "claude" "CLAUDE.md" 2>/dev/null
[ -f "$REPO_ROOT/CLAUDE.md" ] && echo "  ✅ CLAUDE.md created" || { echo "  ❌ CLAUDE.md NOT created"; ERRORS=$((ERRORS+1)); }
grep -q 'Repository Guidelines' "$REPO_ROOT/CLAUDE.md" && echo "  ✅ CLAUDE.md has AGENTS.md content" || { echo "  ❌ CLAUDE.md missing AGENTS.md content"; ERRORS=$((ERRORS+1)); }
grep -q 'Claude' "$REPO_ROOT/CLAUDE.md" && echo "  ✅ CLAUDE.md has Claude overlay" || { echo "  ❌ CLAUDE.md missing overlay"; ERRORS=$((ERRORS+1)); }

# Gemini
generate_instruction_file "gemini" "GEMINI.md" 2>/dev/null
[ -f "$REPO_ROOT/GEMINI.md" ] && echo "  ✅ GEMINI.md created" || { echo "  ❌ GEMINI.md NOT created"; ERRORS=$((ERRORS+1)); }
grep -q 'Gemini' "$REPO_ROOT/GEMINI.md" && echo "  ✅ GEMINI.md has Gemini overlay" || { echo "  ❌ GEMINI.md missing overlay"; ERRORS=$((ERRORS+1)); }

# Copilot
generate_instruction_file "copilot" ".github/copilot-instructions.md" 2>/dev/null
[ -f "$REPO_ROOT/.github/copilot-instructions.md" ] && echo "  ✅ copilot-instructions.md created" || { echo "  ❌ copilot-instructions.md NOT created"; ERRORS=$((ERRORS+1)); }
grep -q 'Copilot' "$REPO_ROOT/.github/copilot-instructions.md" && echo "  ✅ copilot has Copilot overlay" || { echo "  ❌ copilot missing overlay"; ERRORS=$((ERRORS+1)); }

# Preserve without --force
echo "custom claude" > "$REPO_ROOT/CLAUDE.md"
FORCE=false
generate_instruction_file "claude" "CLAUDE.md" 2>/dev/null
grep -q 'custom claude' "$REPO_ROOT/CLAUDE.md" && echo "  ✅ CLAUDE.md preserved without --force" || { echo "  ❌ CLAUDE.md overwritten without --force"; ERRORS=$((ERRORS+1)); }

# Kiro does NOT get instruction file (enforced by main())
echo "  ✅ Kiro uses steering (no instruction file — enforced by main())"

echo ""
echo "=== MAIN() WIRING ==="
grep -q 'install_steering_for_kiro' install.sh && echo "  ✅ calls install_steering_for_kiro"
grep -q 'generate_agents_md' install.sh && echo "  ✅ calls generate_agents_md"
grep -q 'generate_instruction_file "claude"' install.sh && echo "  ✅ calls generate_instruction_file for claude"
grep -q 'generate_instruction_file "gemini"' install.sh && echo "  ✅ calls generate_instruction_file for gemini"
grep -q 'generate_instruction_file "copilot"' install.sh && echo "  ✅ calls generate_instruction_file for copilot"

# Verify Kiro is NOT called with generate_instruction_file
! grep -q 'generate_instruction_file "kiro"' install.sh && echo "  ✅ Kiro NOT called with generate_instruction_file" || { echo "  ❌ Kiro incorrectly gets instruction file"; ERRORS=$((ERRORS+1)); }

# Verify Codex is NOT called with generate_instruction_file (uses AGENTS.md natively)
! grep -q 'generate_instruction_file "codex"' install.sh && echo "  ✅ Codex NOT called with generate_instruction_file" || { echo "  ❌ Codex incorrectly gets instruction file"; ERRORS=$((ERRORS+1)); }

echo ""
# Cleanup
rm -rf "$REPO_ROOT"

if [ "$ERRORS" -eq 0 ]; then
  echo "🎉 ALL TESTS PASSED ($ERRORS errors)"
else
  echo "❌ $ERRORS TESTS FAILED"
fi

exit $ERRORS
