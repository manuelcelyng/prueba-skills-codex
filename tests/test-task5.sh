#!/usr/bin/env bash
set -euo pipefail

# Test script for Task 5 functions
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

SETUP_KIRO=false
SETUP_CODEX=false
SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_COPILOT=false

SCRIPT_DIR="$WORKSPACE_ROOT"

# Source install.sh functions by extracting everything between the function markers.
# We source the whole file but override main() to prevent execution.
# Use a subshell-safe approach: extract function definitions via awk.
extract_func() {
  local func_name="$1"
  local file="$2"
  awk -v fn="$func_name" '
    $0 ~ "^"fn"\\(\\)" { found=1; depth=0 }
    found { print }
    found && /{/ { depth++ }
    found && /}/ { depth--; if (depth==0) { found=0 } }
  ' "$file"
}

eval "$(extract_func update_gitignore "$WORKSPACE_ROOT/install.sh")"
eval "$(extract_func verify_installation "$WORKSPACE_ROOT/install.sh")"
eval "$(extract_func detect_legacy_artifacts "$WORKSPACE_ROOT/install.sh")"
eval "$(extract_func print_summary "$WORKSPACE_ROOT/install.sh")"
eval "$(extract_func run_sync "$WORKSPACE_ROOT/install.sh")"

ERRORS=0

echo "=== TEST 5.1: sync.sh rewrite ==="

# Check header references native agent folders
grep -q "native agent folders" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ header references native agent folders" || { echo "  ❌ header still references .ai/skills"; ERRORS=$((ERRORS+1)); }

# Check --skills-dir flag exists
grep -q "\-\-skills-dir" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ --skills-dir flag present" || { echo "  ❌ --skills-dir flag missing"; ERRORS=$((ERRORS+1)); }

# Check auto-detection logic
grep -q "Auto-detect skills directory" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ auto-detection logic present" || { echo "  ❌ auto-detection logic missing"; ERRORS=$((ERRORS+1)); }

# Check priority order
grep -q ".kiro/skills" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ .kiro/skills in detection" || { echo "  ❌ .kiro/skills missing from detection"; ERRORS=$((ERRORS+1)); }
grep -q ".codex/skills" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ .codex/skills in detection" || { echo "  ❌ .codex/skills missing from detection"; ERRORS=$((ERRORS+1)); }
grep -q ".claude/skills" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ .claude/skills in detection" || { echo "  ❌ .claude/skills missing from detection"; ERRORS=$((ERRORS+1)); }
grep -q ".gemini/skills" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ .gemini/skills in detection" || { echo "  ❌ .gemini/skills missing from detection"; ERRORS=$((ERRORS+1)); }

# Check no reference to old .ai/skills path
! grep -q 'SKILLS_DIR="\$REPO_ROOT/\.ai/skills"' "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ no old .ai/skills path" || { echo "  ❌ still has old .ai/skills path"; ERRORS=$((ERRORS+1)); }

# Check error message references install.sh
grep -q "install.sh" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ error message references install.sh" || { echo "  ❌ error message doesn't reference install.sh"; ERRORS=$((ERRORS+1)); }

# Check no reference to old setup.sh
! grep -q "scripts/ai/setup.sh" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ no reference to old setup.sh" || { echo "  ❌ still references old setup.sh"; ERRORS=$((ERRORS+1)); }

# Check REPO_ROOT uses ../ not ../../
grep -q 'SCRIPT_DIR/\.\.' "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ REPO_ROOT uses ../" || { echo "  ❌ REPO_ROOT path incorrect"; ERRORS=$((ERRORS+1)); }
! grep -q 'SCRIPT_DIR/\.\./\.\.' "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ no ../../ in REPO_ROOT" || { echo "  ❌ still has ../../ in REPO_ROOT"; ERRORS=$((ERRORS+1)); }

# Check frontmatter extraction functions preserved
grep -q "extract_field()" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ extract_field preserved" || { echo "  ❌ extract_field missing"; ERRORS=$((ERRORS+1)); }
grep -q "extract_metadata()" "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ extract_metadata preserved" || { echo "  ❌ extract_metadata missing"; ERRORS=$((ERRORS+1)); }

# Check SmartPay filtering preserved
grep -q 'PROJECT.*smartpay' "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ SmartPay filtering preserved" || { echo "  ❌ SmartPay filtering missing"; ERRORS=$((ERRORS+1)); }

# Check syntax
bash -n "$WORKSPACE_ROOT/tools/sync.sh" && echo "  ✅ sync.sh syntax valid" || { echo "  ❌ sync.sh syntax error"; ERRORS=$((ERRORS+1)); }

echo ""
echo "=== TEST 5.2: update_gitignore ==="

# Test: create new .gitignore with kiro only
SETUP_KIRO=true
SETUP_CODEX=false
SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_COPILOT=false
rm -f "$REPO_ROOT/.gitignore"
update_gitignore 2>/dev/null
[ -f "$REPO_ROOT/.gitignore" ] && echo "  ✅ .gitignore created" || { echo "  ❌ .gitignore NOT created"; ERRORS=$((ERRORS+1)); }
grep -q "# AI KIT (BEGIN)" "$REPO_ROOT/.gitignore" && echo "  ✅ BEGIN marker present" || { echo "  ❌ BEGIN marker missing"; ERRORS=$((ERRORS+1)); }
grep -q "# AI KIT (END)" "$REPO_ROOT/.gitignore" && echo "  ✅ END marker present" || { echo "  ❌ END marker missing"; ERRORS=$((ERRORS+1)); }
grep -q "^\.kiro/$" "$REPO_ROOT/.gitignore" && echo "  ✅ .kiro/ entry present" || { echo "  ❌ .kiro/ entry missing"; ERRORS=$((ERRORS+1)); }
! grep -q "^\.codex/$" "$REPO_ROOT/.gitignore" && echo "  ✅ .codex/ NOT present (not selected)" || { echo "  ❌ .codex/ present but not selected"; ERRORS=$((ERRORS+1)); }

# Test: no legacy entries
! grep -q "\.ai-kit/" "$REPO_ROOT/.gitignore" && echo "  ✅ no .ai-kit/ entry" || { echo "  ❌ has .ai-kit/ entry"; ERRORS=$((ERRORS+1)); }
! grep -q "^\.ai/$" "$REPO_ROOT/.gitignore" && echo "  ✅ no .ai/ entry" || { echo "  ❌ has .ai/ entry"; ERRORS=$((ERRORS+1)); }

# Test: all agents selected
SETUP_KIRO=true
SETUP_CODEX=true
SETUP_CLAUDE=true
SETUP_GEMINI=true
SETUP_COPILOT=true
update_gitignore 2>/dev/null || true
grep -q "^\.kiro/$" "$REPO_ROOT/.gitignore" && echo "  ✅ .kiro/ present (all)" || { echo "  ❌ .kiro/ missing (all)"; ERRORS=$((ERRORS+1)); }
grep -q "^\.codex/$" "$REPO_ROOT/.gitignore" && echo "  ✅ .codex/ present (all)" || { echo "  ❌ .codex/ missing (all)"; ERRORS=$((ERRORS+1)); }
grep -q "^\.claude/$" "$REPO_ROOT/.gitignore" && echo "  ✅ .claude/ present (all)" || { echo "  ❌ .claude/ missing (all)"; ERRORS=$((ERRORS+1)); }
grep -q "^\.gemini/$" "$REPO_ROOT/.gitignore" && echo "  ✅ .gemini/ present (all)" || { echo "  ❌ .gemini/ missing (all)"; ERRORS=$((ERRORS+1)); }
grep -q "copilot-instructions.md" "$REPO_ROOT/.gitignore" && echo "  ✅ copilot-instructions.md present (all)" || { echo "  ❌ copilot-instructions.md missing (all)"; ERRORS=$((ERRORS+1)); }
grep -q "^CLAUDE\.md$" "$REPO_ROOT/.gitignore" && echo "  ✅ CLAUDE.md present (all)" || { echo "  ❌ CLAUDE.md missing (all)"; ERRORS=$((ERRORS+1)); }
grep -q "^GEMINI\.md$" "$REPO_ROOT/.gitignore" && echo "  ✅ GEMINI.md present (all)" || { echo "  ❌ GEMINI.md missing (all)"; ERRORS=$((ERRORS+1)); }

# Test: idempotent replacement
echo "existing content" > "$REPO_ROOT/.gitignore"
echo "# AI KIT (BEGIN)" >> "$REPO_ROOT/.gitignore"
echo ".old-entry/" >> "$REPO_ROOT/.gitignore"
echo "# AI KIT (END)" >> "$REPO_ROOT/.gitignore"
echo "more content" >> "$REPO_ROOT/.gitignore"
SETUP_KIRO=true
SETUP_CODEX=false
SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_COPILOT=false
update_gitignore 2>/dev/null
grep -q "existing content" "$REPO_ROOT/.gitignore" && echo "  ✅ preserved content before block" || { echo "  ❌ lost content before block"; ERRORS=$((ERRORS+1)); }
grep -q "more content" "$REPO_ROOT/.gitignore" && echo "  ✅ preserved content after block" || { echo "  ❌ lost content after block"; ERRORS=$((ERRORS+1)); }
! grep -q "\.old-entry/" "$REPO_ROOT/.gitignore" && echo "  ✅ old block content replaced" || { echo "  ❌ old block content still present"; ERRORS=$((ERRORS+1)); }
grep -q "^\.kiro/$" "$REPO_ROOT/.gitignore" && echo "  ✅ new block content present" || { echo "  ❌ new block content missing"; ERRORS=$((ERRORS+1)); }
# Count markers — should be exactly 1 of each
begin_count=$(grep -c "# AI KIT (BEGIN)" "$REPO_ROOT/.gitignore")
end_count=$(grep -c "# AI KIT (END)" "$REPO_ROOT/.gitignore")
[ "$begin_count" -eq 1 ] && echo "  ✅ exactly 1 BEGIN marker" || { echo "  ❌ $begin_count BEGIN markers"; ERRORS=$((ERRORS+1)); }
[ "$end_count" -eq 1 ] && echo "  ✅ exactly 1 END marker" || { echo "  ❌ $end_count END markers"; ERRORS=$((ERRORS+1)); }

# Test: append to existing .gitignore without block
echo "node_modules/" > "$REPO_ROOT/.gitignore"
update_gitignore 2>/dev/null
grep -q "node_modules/" "$REPO_ROOT/.gitignore" && echo "  ✅ existing content preserved (append)" || { echo "  ❌ existing content lost (append)"; ERRORS=$((ERRORS+1)); }
grep -q "# AI KIT (BEGIN)" "$REPO_ROOT/.gitignore" && echo "  ✅ block appended" || { echo "  ❌ block not appended"; ERRORS=$((ERRORS+1)); }

echo ""
echo "=== TEST 5.3: verify_installation ==="

# Setup: create valid installation for kiro
SETUP_KIRO=true
SETUP_CODEX=false
SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_COPILOT=false
mkdir -p "$REPO_ROOT/.kiro/skills/test-skill"
mkdir -p "$REPO_ROOT/.kiro/references"
echo "ref" > "$REPO_ROOT/.kiro/references/test.md"
mkdir -p "$REPO_ROOT/.kiro/steering"
echo "steering" > "$REPO_ROOT/.kiro/steering/main.md"

verify_installation 2>/dev/null && echo "  ✅ verification passed (valid kiro)" || { echo "  ❌ verification failed (valid kiro)"; ERRORS=$((ERRORS+1)); }

# Test: missing skills dir
rm -rf "$REPO_ROOT/.kiro/skills"
verify_output=$(verify_installation 2>&1 || true)
echo "$verify_output" | grep -q "verification failed" && echo "  ✅ detected missing skills dir" || { echo "  ❌ didn't detect missing skills dir"; ERRORS=$((ERRORS+1)); }

# Restore and test empty skills dir
mkdir -p "$REPO_ROOT/.kiro/skills"
verify_output=$(verify_installation 2>&1 || true)
echo "$verify_output" | grep -q "empty" && echo "  ✅ detected empty skills dir" || { echo "  ❌ didn't detect empty skills dir"; ERRORS=$((ERRORS+1)); }

# Restore skills, remove references
mkdir -p "$REPO_ROOT/.kiro/skills/test-skill"
rm -rf "$REPO_ROOT/.kiro/references"
verify_output=$(verify_installation 2>&1 || true)
echo "$verify_output" | grep -q "references" && echo "  ✅ detected missing references dir" || { echo "  ❌ didn't detect missing references dir"; ERRORS=$((ERRORS+1)); }

# Restore references, remove steering
mkdir -p "$REPO_ROOT/.kiro/references"
echo "ref" > "$REPO_ROOT/.kiro/references/test.md"
rm -rf "$REPO_ROOT/.kiro/steering"
verify_output=$(verify_installation 2>&1 || true)
echo "$verify_output" | grep -q "steering" && echo "  ✅ detected missing steering dir" || { echo "  ❌ didn't detect missing steering dir"; ERRORS=$((ERRORS+1)); }

# Test: exit code != 0 on failure
mkdir -p "$REPO_ROOT/.kiro/steering"
# steering dir exists but empty
if verify_installation 2>/dev/null; then
  echo "  ❌ should have failed (empty steering)"
  ERRORS=$((ERRORS+1))
else
  echo "  ✅ exit code != 0 on failure"
fi

# Restore for next tests
echo "steering" > "$REPO_ROOT/.kiro/steering/main.md"

# Test: multiple agents
SETUP_KIRO=true
SETUP_CODEX=true
mkdir -p "$REPO_ROOT/.codex/skills/test-skill"
mkdir -p "$REPO_ROOT/.codex/references"
echo "ref" > "$REPO_ROOT/.codex/references/test.md"
verify_installation 2>/dev/null && echo "  ✅ verification passed (kiro + codex)" || { echo "  ❌ verification failed (kiro + codex)"; ERRORS=$((ERRORS+1)); }
SETUP_CODEX=false

echo ""
echo "=== TEST 5.4: detect_legacy_artifacts ==="

# Test: no legacy artifacts
legacy_output=$(detect_legacy_artifacts 2>&1)
! echo "$legacy_output" | grep -q "detected" && echo "  ✅ no warnings when clean" || { echo "  ❌ false warnings on clean repo"; ERRORS=$((ERRORS+1)); }

# Test: .ai-kit/ detected
mkdir -p "$REPO_ROOT/.ai-kit"
legacy_output=$(detect_legacy_artifacts 2>&1)
echo "$legacy_output" | grep -q ".ai-kit/" && echo "  ✅ detected .ai-kit/" || { echo "  ❌ didn't detect .ai-kit/"; ERRORS=$((ERRORS+1)); }
rm -rf "$REPO_ROOT/.ai-kit"

# Test: .ai/ detected
mkdir -p "$REPO_ROOT/.ai"
legacy_output=$(detect_legacy_artifacts 2>&1)
echo "$legacy_output" | grep -q ".ai/" && echo "  ✅ detected .ai/" || { echo "  ❌ didn't detect .ai/"; ERRORS=$((ERRORS+1)); }
rm -rf "$REPO_ROOT/.ai"

# Test: scripts/ai/ detected
mkdir -p "$REPO_ROOT/scripts/ai"
legacy_output=$(detect_legacy_artifacts 2>&1)
echo "$legacy_output" | grep -q "scripts/ai/" && echo "  ✅ detected scripts/ai/" || { echo "  ❌ didn't detect scripts/ai/"; ERRORS=$((ERRORS+1)); }
rm -rf "$REPO_ROOT/scripts"

# Test: ai-kit.lock detected
touch "$REPO_ROOT/ai-kit.lock"
legacy_output=$(detect_legacy_artifacts 2>&1)
echo "$legacy_output" | grep -q "ai-kit.lock" && echo "  ✅ detected ai-kit.lock" || { echo "  ❌ didn't detect ai-kit.lock"; ERRORS=$((ERRORS+1)); }
rm -f "$REPO_ROOT/ai-kit.lock"

# Test: all legacy artifacts at once
mkdir -p "$REPO_ROOT/.ai-kit" "$REPO_ROOT/.ai" "$REPO_ROOT/scripts/ai"
touch "$REPO_ROOT/ai-kit.lock"
legacy_output=$(detect_legacy_artifacts 2>&1)
echo "$legacy_output" | grep -q ".ai-kit/" && echo "  ✅ detected .ai-kit/ (all)" || { echo "  ❌ missed .ai-kit/ (all)"; ERRORS=$((ERRORS+1)); }
echo "$legacy_output" | grep -q ".ai/" && echo "  ✅ detected .ai/ (all)" || { echo "  ❌ missed .ai/ (all)"; ERRORS=$((ERRORS+1)); }
echo "$legacy_output" | grep -q "scripts/ai/" && echo "  ✅ detected scripts/ai/ (all)" || { echo "  ❌ missed scripts/ai/ (all)"; ERRORS=$((ERRORS+1)); }
echo "$legacy_output" | grep -q "ai-kit.lock" && echo "  ✅ detected ai-kit.lock (all)" || { echo "  ❌ missed ai-kit.lock (all)"; ERRORS=$((ERRORS+1)); }
rm -rf "$REPO_ROOT/.ai-kit" "$REPO_ROOT/.ai" "$REPO_ROOT/scripts" "$REPO_ROOT/ai-kit.lock"

# Test: installation continues (function returns 0)
mkdir -p "$REPO_ROOT/.ai-kit"
detect_legacy_artifacts 2>/dev/null
echo "  ✅ installation continues despite legacy artifacts"
rm -rf "$REPO_ROOT/.ai-kit"

echo ""
echo "=== TEST 5.5: print_summary ==="

# Setup valid installation
SETUP_KIRO=true
SETUP_CODEX=false
SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_COPILOT=false
mkdir -p "$REPO_ROOT/.kiro/skills/skill-a" "$REPO_ROOT/.kiro/skills/skill-b"
mkdir -p "$REPO_ROOT/.kiro/references"
echo "ref1" > "$REPO_ROOT/.kiro/references/ref1.md"
echo "ref2" > "$REPO_ROOT/.kiro/references/ref2.md"
mkdir -p "$REPO_ROOT/.kiro/steering"
echo "steer" > "$REPO_ROOT/.kiro/steering/main.md"

summary_output=$(print_summary 2>&1)
echo "$summary_output" | grep -q "Installation Summary" && echo "  ✅ summary header present" || { echo "  ❌ summary header missing"; ERRORS=$((ERRORS+1)); }
echo "$summary_output" | grep -q "kiro" && echo "  ✅ kiro in summary" || { echo "  ❌ kiro missing from summary"; ERRORS=$((ERRORS+1)); }
echo "$summary_output" | grep -q "verified successfully" && echo "  ✅ success message present" || { echo "  ❌ success message missing"; ERRORS=$((ERRORS+1)); }

# Test with copilot
SETUP_COPILOT=true
summary_output=$(print_summary 2>&1)
echo "$summary_output" | grep -q "copilot" && echo "  ✅ copilot in summary" || { echo "  ❌ copilot missing from summary"; ERRORS=$((ERRORS+1)); }
SETUP_COPILOT=false

echo ""
echo "=== MAIN() WIRING ==="
grep -q 'run_sync' install.sh && echo "  ✅ calls run_sync" || { echo "  ❌ missing run_sync call"; ERRORS=$((ERRORS+1)); }
grep -q 'update_gitignore' install.sh && echo "  ✅ calls update_gitignore" || { echo "  ❌ missing update_gitignore call"; ERRORS=$((ERRORS+1)); }
grep -q 'verify_installation' install.sh && echo "  ✅ calls verify_installation" || { echo "  ❌ missing verify_installation call"; ERRORS=$((ERRORS+1)); }
grep -q 'detect_legacy_artifacts' install.sh && echo "  ✅ calls detect_legacy_artifacts" || { echo "  ❌ missing detect_legacy_artifacts call"; ERRORS=$((ERRORS+1)); }
grep -q 'print_summary' install.sh && echo "  ✅ calls print_summary" || { echo "  ❌ missing print_summary call"; ERRORS=$((ERRORS+1)); }

# Verify order: run_sync before update_gitignore before verify_installation
run_sync_line=$(grep -n 'run_sync' install.sh | head -1 | cut -d: -f1)
gitignore_line=$(grep -n 'update_gitignore' install.sh | grep -v "^#" | head -1 | cut -d: -f1)
verify_line=$(grep -n 'verify_installation' install.sh | grep -v "^#" | head -1 | cut -d: -f1)
legacy_line=$(grep -n 'detect_legacy_artifacts' install.sh | grep -v "^#" | head -1 | cut -d: -f1)
summary_line=$(grep -n 'print_summary' install.sh | grep -v "^#" | head -1 | cut -d: -f1)

# Check no TODO placeholders remain
! grep -q "# TODO:" install.sh && echo "  ✅ no TODO placeholders remain" || { echo "  ❌ TODO placeholders still present"; ERRORS=$((ERRORS+1)); }

echo ""
# Cleanup
rm -rf "$REPO_ROOT"

if [ "$ERRORS" -eq 0 ]; then
  echo "🎉 ALL TESTS PASSED ($ERRORS errors)"
else
  echo "❌ $ERRORS TESTS FAILED"
fi

exit $ERRORS
