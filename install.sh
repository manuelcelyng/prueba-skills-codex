#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="${REPO_ROOT:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/tools/lib.sh" ]; then source "$SCRIPT_DIR/tools/lib.sh"; fi

KIT_REPO="https://github.com/manuelcelyng/prueba-skills-codex.git"
KIT_REF="main"; PROJECT="smartpay"; FORCE=false; NO_SETUP=false
SETUP_KIRO=false; SETUP_CODEX=false; SETUP_CLAUDE=false; SETUP_GEMINI=false; SETUP_COPILOT=false
KIT_DIR=""; is_java=false; is_python=false; is_workspace=false

parse_args() { while [ $# -gt 0 ]; do case "$1" in
  --kit-repo) KIT_REPO="$2"; shift 2;; --kit-ref) KIT_REF="$2"; shift 2;; --project) PROJECT="$2"; shift 2;;
  --kiro) SETUP_KIRO=true; shift;; --codex) SETUP_CODEX=true; shift;; --claude) SETUP_CLAUDE=true; shift;;
  --gemini) SETUP_GEMINI=true; shift;; --copilot) SETUP_COPILOT=true; shift;;
  --all) SETUP_KIRO=true;SETUP_CODEX=true;SETUP_CLAUDE=true;SETUP_GEMINI=true;SETUP_COPILOT=true; shift;;
  --force) FORCE=true; shift;; --no-setup) NO_SETUP=true; shift;;
  --help|-h) echo "install.sh [--kit-repo url] [--kit-ref ref] [--project name] [--kiro|--codex|--all] [--force]"; exit 0;;
  *) err "Unknown: $1"; exit 1;; esac; done; }

download_kit() {
  if [ -d "$KIT_REPO" ]; then
    KIT_DIR="$(mktemp -d)"; setup_cleanup; cp -R "$KIT_REPO"/. "$KIT_DIR"/; log "ai-kit from local path"; return 0; fi
  KIT_DIR="$(mktemp -d)"; setup_cleanup; log "downloading ($KIT_REF)..."
  local ok=false; for i in 1 2 3; do rm -rf "$KIT_DIR"; KIT_DIR="$(mktemp -d)"
    if git clone "$KIT_REPO" "$KIT_DIR" >/dev/null 2>&1; then ok=true; break; fi; sleep "$i"; done
  if $ok; then if [ -d "$KIT_DIR/.git" ]; then git -C "$KIT_DIR" checkout -q "$KIT_REF" 2>/dev/null || true; fi
    log "downloaded (git clone)"; return 0; fi
  local src="${KIT_REPO%.git}" owner="" repo=""
  if [[ "$src" =~ github\.com/([^/]+)/([^/]+) ]]; then owner="${BASH_REMATCH[1]}"; repo="${BASH_REMATCH[2]}"; fi
  if [ -z "$owner" ]; then err "clone failed"; exit 1; fi
  local url="https://codeload.github.com/$owner/$repo/tar.gz/$KIT_REF" tgz="$KIT_DIR/k.tgz"
  warn "trying tarball..."; local dl=false
  for i in 1 2 3; do if curl -fsSL -o "$tgz" "$url" 2>/dev/null; then dl=true; break; fi; sleep "$i"; done
  if ! $dl; then err "tarball failed"; exit 1; fi
  tar -xzf "$tgz" -C "$KIT_DIR"
  local ex; ex="$(find "$KIT_DIR" -maxdepth 1 -type d -name "${repo}-*" | head -1)"
  if [ ! -d "$ex" ]; then err "extract failed"; exit 1; fi
  local t; t="$(mktemp -d)"; mv "$ex"/* "$t"/; rm -rf "$KIT_DIR"; mv "$t" "$KIT_DIR"; log "downloaded (tarball)"; }

show_menu() {
  if $SETUP_KIRO || $SETUP_CODEX || $SETUP_CLAUDE || $SETUP_GEMINI || $SETUP_COPILOT; then return 0; fi
  if [ ! -t 0 ]; then warn "no TTY — defaulting to --kiro"; SETUP_KIRO=true; return 0; fi
  echo "Which agents? (Enter=Kiro) 1)Kiro 2)Codex 3)Claude 4)Gemini 5)Copilot a)All n)None"
  printf "Select: "; local c=""; read -r c < /dev/tty 2>/dev/null || read -r c || c=""
  case "$c" in "") SETUP_KIRO=true;; a|A) SETUP_KIRO=true;SETUP_CODEX=true;SETUP_CLAUDE=true;SETUP_GEMINI=true;SETUP_COPILOT=true;;
    n|N) ;; *) for x in $c; do case "$x" in 1)SETUP_KIRO=true;;2)SETUP_CODEX=true;;3)SETUP_CLAUDE=true;;4)SETUP_GEMINI=true;;5)SETUP_COPILOT=true;;esac;done;; esac; }

filter_skills() {
  local kd="$KIT_DIR/skills" ld="$REPO_ROOT/skills" names=""
  if [ -d "$kd" ]; then for d in "$kd"/*/; do if [ -d "$d" ]; then local n; n="$(basename "$d")"
    if should_include_skill "$n"; then echo "$d"; names="$names $n "; fi; fi; done; fi
  if [ -d "$ld" ]; then for d in "$ld"/*/; do if [ -d "$d" ]; then local n; n="$(basename "$d")"
    case "$names" in *" $n "*) ;; *) echo "$d";; esac; fi; done; fi; }

install_skills_for_agent() {
  local a="$1" dest="$REPO_ROOT/.${1}/skills"; rm -rf "$dest"; mkdir -p "$dest"; local c=0
  while IFS= read -r p; do if [ -n "$p" ] && [ -d "$p" ]; then cp -R "$p" "$dest/$(basename "$p")"; c=$((c+1)); fi
  done <<SK
$(filter_skills)
SK
  log "$a: $c skills"; }

install_references_for_agent() {
  local a="$1" src="$KIT_DIR/references" dest="$REPO_ROOT/.${1}/references"
  if [ ! -d "$src" ]; then warn "$a: no refs"; return 0; fi
  rm -rf "$dest"; mkdir -p "$dest"; cp -R "$src"/* "$dest"/ 2>/dev/null || true
  log "$a: $(find "$dest" -type f | wc -l | tr -d ' ') refs"; }

install_steering_for_kiro() {
  local d="$REPO_ROOT/.kiro/steering"; mkdir -p "$d"
  if [ ! -f "$d/main.md" ] || [ "$FORCE" = "true" ]; then
    printf '%s\n' '---' 'inclusion: always' 'name: ai-kit-main' 'description: Reglas principales del kit AI.' '---' '' '# AI Kit Main' '- AGENTS.md | .kiro/skills/ | .kiro/references/ | references/sdd/sdd-playbook.md' > "$d/main.md"
    log "kiro: main.md"; fi
  if [ ! -f "$d/collaboration.md" ] || [ "$FORCE" = "true" ]; then
    printf '%s\n' '---' 'inclusion: auto' 'name: ai-kit-collaboration' 'description: GitLab/Azure DevOps collaboration.' '---' '' '# Collaboration' '- gitlab-mr-review-* | azuredevops | pr-description' > "$d/collaboration.md"
    log "kiro: collaboration.md"; fi; }

generate_agents_md() {
  if [ -f "$REPO_ROOT/AGENTS.md" ] && [ "$FORCE" != "true" ]; then log "AGENTS.md exists"; return 0; fi
  printf '%s\n' "# $(basename "$REPO_ROOT")" "" "Invoca ai-init-agents en el primer contacto." "" "SDD: smartpay-sdd-orchestrator | Playbook: references/sdd/sdd-playbook.md" > "$REPO_ROOT/AGENTS.md"
  log "AGENTS.md stub"; }

generate_instruction_file() {
  local a="$1" out="$REPO_ROOT/$2"
  if [ -f "$out" ] && [ "$FORCE" != "true" ]; then log "$a: $2 exists"; return 0; fi
  if [ ! -f "$REPO_ROOT/AGENTS.md" ]; then warn "$a: no AGENTS.md"; return 0; fi
  mkdir -p "$(dirname "$out")"; cp "$REPO_ROOT/AGENTS.md" "$out"
  local ov="$KIT_DIR/references/sdd/assistant-overlays/${a}.md"
  if [ -f "$ov" ]; then printf '\n' >> "$out"; cat "$ov" >> "$out"; fi; log "$a: $2"; }

run_sync() {
  local s=""
  if [ -f "$SCRIPT_DIR/tools/sync.sh" ]; then s="$SCRIPT_DIR/tools/sync.sh"
  elif [ -f "$KIT_DIR/tools/sync.sh" ]; then s="$KIT_DIR/tools/sync.sh"; fi
  if [ -z "$s" ]; then warn "no sync.sh"; return 0; fi
  local sd=""
  for c in .kiro/skills .codex/skills .claude/skills .gemini/skills; do
    if [ -d "$REPO_ROOT/$c" ]; then sd="$REPO_ROOT/$c"; break; fi; done
  if [ -z "$sd" ]; then warn "no skills for sync"; return 0; fi
  REPO_ROOT="$REPO_ROOT" AI_SKILLS_PROJECT="$PROJECT" bash "$s" --skills-dir "$sd" 2>&1 || true; }

update_gitignore() {
  local gi="$REPO_ROOT/.gitignore" bm="# AI KIT (BEGIN)" em="# AI KIT (END)"
  local bf; bf="$(mktemp)"; echo "$bm" > "$bf"
  if $SETUP_KIRO; then echo ".kiro/" >> "$bf"; fi
  if $SETUP_CODEX; then echo ".codex/" >> "$bf"; fi
  if $SETUP_CLAUDE; then echo ".claude/" >> "$bf"; echo "CLAUDE.md" >> "$bf"; fi
  if $SETUP_GEMINI; then echo ".gemini/" >> "$bf"; echo "GEMINI.md" >> "$bf"; fi
  if $SETUP_COPILOT; then echo ".github/copilot-instructions.md" >> "$bf"; fi
  echo "$em" >> "$bf"
  if [ ! -f "$gi" ]; then cp "$bf" "$gi"; rm -f "$bf"; log ".gitignore created"; return 0; fi
  if grep -qF "$bm" "$gi"; then
    local t; t="$(mktemp)"
    awk -v b="$bm" -v e="$em" -v f="$bf" '$0==b{while((getline l<f)>0)print l;close(f);sk=1;next}sk&&$0==e{sk=0;next}!sk{print}' "$gi" > "$t"
    mv "$t" "$gi"; rm -f "$bf"; log ".gitignore updated"
  else echo "" >> "$gi"; cat "$bf" >> "$gi"; rm -f "$bf"; log ".gitignore appended"; fi; }

verify_installation() {
  local fail=false
  for a in $1; do
    if [ ! -d "$REPO_ROOT/.${a}/skills" ] || [ "$(find "$REPO_ROOT/.${a}/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')" -eq 0 ]; then err "verify: .${a}/skills"; fail=true; fi
    if [ ! -d "$REPO_ROOT/.${a}/references" ] || [ "$(find "$REPO_ROOT/.${a}/references" -type f 2>/dev/null | wc -l | tr -d ' ')" -eq 0 ]; then err "verify: .${a}/refs"; fail=true; fi
  done
  if $SETUP_KIRO; then
    if [ ! -d "$REPO_ROOT/.kiro/steering" ] || [ "$(find "$REPO_ROOT/.kiro/steering" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 0 ]; then err "verify: steering"; fail=true; fi; fi
  if $fail; then return 1; fi; return 0; }

detect_legacy() {
  if [ -d "$REPO_ROOT/.ai-kit" ]; then warn "legacy: .ai-kit/"; fi
  if [ -d "$REPO_ROOT/.ai" ]; then warn "legacy: .ai/"; fi
  if [ -d "$REPO_ROOT/scripts/ai" ]; then warn "legacy: scripts/ai/"; fi
  if [ -f "$REPO_ROOT/ai-kit.lock" ]; then warn "legacy: ai-kit.lock"; fi; }

print_summary() {
  log "=== Summary ==="
  for a in $1; do
    local sc; sc="$(find "$REPO_ROOT/.${a}/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
    local rc; rc="$(find "$REPO_ROOT/.${a}/references" -type f 2>/dev/null | wc -l | tr -d ' ')"
    local st="-"; if [ "$a" = "kiro" ]; then st="$(find "$REPO_ROOT/.kiro/steering" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"; fi
    log "  $a: $sc skills, $rc refs, $st steering"
  done; }

main() {
  parse_args "$@"
  if [ ! -d "$REPO_ROOT/.git" ]; then err "not a git repo: $REPO_ROOT"; exit 1; fi
  download_kit
  if [ -f "$KIT_DIR/tools/lib.sh" ]; then source "$KIT_DIR/tools/lib.sh"; fi
  detect_stack "$REPO_ROOT"
  if $NO_SETUP; then log "done (--no-setup)"; return 0; fi
  show_menu
  if ! $SETUP_KIRO && ! $SETUP_CODEX && ! $SETUP_CLAUDE && ! $SETUP_GEMINI && ! $SETUP_COPILOT; then warn "no agents"; return 0; fi
  local agents=""
  if $SETUP_KIRO; then agents="$agents kiro"; fi
  if $SETUP_CODEX; then agents="$agents codex"; fi
  if $SETUP_CLAUDE; then agents="$agents claude"; fi
  if $SETUP_GEMINI; then agents="$agents gemini"; fi
  for a in $agents; do install_skills_for_agent "$a"; install_references_for_agent "$a"; done
  if $SETUP_KIRO; then install_steering_for_kiro; fi
  generate_agents_md
  if $SETUP_CLAUDE; then generate_instruction_file "claude" "CLAUDE.md"; fi
  if $SETUP_GEMINI; then generate_instruction_file "gemini" "GEMINI.md"; fi
  if $SETUP_COPILOT; then generate_instruction_file "copilot" ".github/copilot-instructions.md"; fi
  run_sync; update_gitignore
  if verify_installation "$agents"; then print_summary "$agents"; fi
  detect_legacy; log "complete"; }

main "$@"
