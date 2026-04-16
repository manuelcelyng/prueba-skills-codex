#!/usr/bin/env bash
# AI Kit installer — direct-copy model (curl|bash safe).
set -eo pipefail

REPO_ROOT="${REPO_ROOT:-$(pwd)}"
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Inline fallbacks (overridden when lib.sh loads from downloaded kit)
log()  { printf '\033[0;32minstall:\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33minstall:\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[0;31minstall:\033[0m %s\n' "$*" >&2; }
setup_cleanup() { trap '_do_cleanup' EXIT; }
_do_cleanup() { [ -n "${KIT_DIR:-}" ] && [ -d "${KIT_DIR:-}" ] && rm -rf "$KIT_DIR" || true; }
is_java=false; is_python=false; is_workspace=false
detect_stack() {
  local r="${1:-.}"; is_java=false; is_python=false; is_workspace=false
  { [ -f "$r/gradlew" ] || [ -f "$r/build.gradle" ] || [ -f "$r/build.gradle.kts" ]; } && is_java=true || true
  { [ -f "$r/pyproject.toml" ] || [ -f "$r/requirements.txt" ] || [ -f "$r/template.yaml" ]; } && is_python=true || true
}
should_include_skill() { return 0; }

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/tools/lib.sh" ]; then source "$SCRIPT_DIR/tools/lib.sh"; fi

KIT_REPO="https://github.com/manuelcelyng/prueba-skills-codex.git"
KIT_REF="main"; PROJECT="smartpay"; FORCE=false; NO_SETUP=false
SETUP_KIRO=false; SETUP_CODEX=false; SETUP_CLAUDE=false; SETUP_GEMINI=false; SETUP_COPILOT=false
KIT_DIR=""

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
  local ok=false
  for i in 1 2 3; do rm -rf "$KIT_DIR"; KIT_DIR="$(mktemp -d)"
    git clone "$KIT_REPO" "$KIT_DIR" >/dev/null 2>&1 && ok=true && break; sleep "$i"; done
  if $ok; then [ -d "$KIT_DIR/.git" ] && git -C "$KIT_DIR" checkout -q "$KIT_REF" 2>/dev/null || true
    log "downloaded (git clone)"; return 0; fi
  local src="${KIT_REPO%.git}" owner="" repo=""
  [[ "$src" =~ github\.com/([^/]+)/([^/]+) ]] && owner="${BASH_REMATCH[1]}" && repo="${BASH_REMATCH[2]}"
  [ -z "$owner" ] && { err "clone failed"; exit 1; }
  local url="https://codeload.github.com/$owner/$repo/tar.gz/$KIT_REF" tgz="$KIT_DIR/k.tgz"
  warn "trying tarball..."
  local dl=false; for i in 1 2 3; do curl -fsSL -o "$tgz" "$url" 2>/dev/null && dl=true && break; sleep "$i"; done
  $dl || { err "tarball failed"; exit 1; }
  tar -xzf "$tgz" -C "$KIT_DIR"
  local ex; ex="$(find "$KIT_DIR" -maxdepth 1 -type d -name "${repo}-*" | head -1)"
  [ -d "$ex" ] || { err "extract failed"; exit 1; }
  local t; t="$(mktemp -d)"; mv "$ex"/* "$t"/; rm -rf "$KIT_DIR"; mv "$t" "$KIT_DIR"; log "downloaded (tarball)"; }

show_menu() {
  $SETUP_KIRO || $SETUP_CODEX || $SETUP_CLAUDE || $SETUP_GEMINI || $SETUP_COPILOT && return 0 || true
  if [ ! -t 0 ] && ! exec 3<>/dev/tty 2>/dev/null; then warn "no TTY — defaulting to --kiro"; SETUP_KIRO=true; return 0; fi
  exec 3<&- 2>/dev/null || true; exec 3>&- 2>/dev/null || true
  echo "Which agents? (Enter=Kiro) 1)Kiro 2)Codex 3)Claude 4)Gemini 5)Copilot a)All n)None"
  printf "Select: "; local c=""; read -r c < /dev/tty 2>/dev/null || read -r c || c=""
  case "$c" in "") SETUP_KIRO=true;; a|A) SETUP_KIRO=true;SETUP_CODEX=true;SETUP_CLAUDE=true;SETUP_GEMINI=true;SETUP_COPILOT=true;;
    n|N) ;; *) for x in $c; do case "$x" in 1)SETUP_KIRO=true;;2)SETUP_CODEX=true;;3)SETUP_CLAUDE=true;;4)SETUP_GEMINI=true;;5)SETUP_COPILOT=true;;esac;done;; esac; }

filter_skills() {
  local kd="$KIT_DIR/skills" ld="$REPO_ROOT/skills" names=""
  if [ -d "$kd" ]; then for d in "$kd"/*/; do [ -d "$d" ] || continue; local n; n="$(basename "$d")"
    should_include_skill "$n" && { echo "$d"; names="$names $n "; }; done; fi
  if [ -d "$ld" ]; then for d in "$ld"/*/; do [ -d "$d" ] || continue; local n; n="$(basename "$d")"
    case "$names" in *" $n "*) ;; *) echo "$d";; esac; done; fi; }

install_skills_for_agent() {
  local a="$1" dest="$REPO_ROOT/.${1}/skills"; rm -rf "$dest"; mkdir -p "$dest"; local c=0
  while IFS= read -r p; do [ -n "$p" ] && [ -d "$p" ] && { cp -R "$p" "$dest/$(basename "$p")"; c=$((c+1)); }
  done <<SK
$(filter_skills)
SK
  log "$a: $c skills"; }

install_references_for_agent() {
  local a="$1" src="$KIT_DIR/references" dest="$REPO_ROOT/.${1}/references"
  [ -d "$src" ] || { warn "$a: no refs"; return 0; }
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
  [ -f "$REPO_ROOT/AGENTS.md" ] && [ "$FORCE" != "true" ] && { log "AGENTS.md exists"; return 0; }
  printf '%s\n' "# $(basename "$REPO_ROOT")" "" "Invoca ai-init-agents en el primer contacto." "" "SDD: smartpay-sdd-orchestrator | Playbook: references/sdd/sdd-playbook.md" > "$REPO_ROOT/AGENTS.md"
  log "AGENTS.md stub"; }

generate_instruction_file() {
  local a="$1" out="$REPO_ROOT/$2"
  [ -f "$out" ] && [ "$FORCE" != "true" ] && { log "$a: $2 exists"; return 0; }
  [ -f "$REPO_ROOT/AGENTS.md" ] || { warn "$a: no AGENTS.md"; return 0; }
  mkdir -p "$(dirname "$out")"; cp "$REPO_ROOT/AGENTS.md" "$out"
  local ov="$KIT_DIR/references/sdd/assistant-overlays/${a}.md"
  [ -f "$ov" ] && { printf '\n' >> "$out"; cat "$ov" >> "$out"; }; log "$a: $2"; }

run_sync() {
  local s=""
  [ -n "${SCRIPT_DIR:-}" ] && [ -f "$SCRIPT_DIR/tools/sync.sh" ] && s="$SCRIPT_DIR/tools/sync.sh"
  [ -z "$s" ] && [ -f "$KIT_DIR/tools/sync.sh" ] && s="$KIT_DIR/tools/sync.sh"
  [ -z "$s" ] && { warn "no sync.sh"; return 0; }
  local sd=""
  for c in .kiro/skills .codex/skills .claude/skills .gemini/skills; do
    [ -d "$REPO_ROOT/$c" ] && { sd="$REPO_ROOT/$c"; break; }; done
  [ -z "$sd" ] && { warn "no skills for sync"; return 0; }
  REPO_ROOT="$REPO_ROOT" AI_SKILLS_PROJECT="$PROJECT" bash "$s" --skills-dir "$sd" 2>&1 || true; }

update_gitignore() {
  local gi="$REPO_ROOT/.gitignore" bm="# AI KIT (BEGIN)" em="# AI KIT (END)"
  local bf; bf="$(mktemp)"; echo "$bm" > "$bf"
  $SETUP_KIRO && echo ".kiro/" >> "$bf"; $SETUP_CODEX && echo ".codex/" >> "$bf"
  $SETUP_CLAUDE && { echo ".claude/" >> "$bf"; echo "CLAUDE.md" >> "$bf"; }
  $SETUP_GEMINI && { echo ".gemini/" >> "$bf"; echo "GEMINI.md" >> "$bf"; }
  $SETUP_COPILOT && echo ".github/copilot-instructions.md" >> "$bf"
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
    [ -d "$REPO_ROOT/.${a}/skills" ] && [ "$(find "$REPO_ROOT/.${a}/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')" -gt 0 ] || { err "verify: .${a}/skills"; fail=true; }
    [ -d "$REPO_ROOT/.${a}/references" ] && [ "$(find "$REPO_ROOT/.${a}/references" -type f 2>/dev/null | wc -l | tr -d ' ')" -gt 0 ] || { err "verify: .${a}/refs"; fail=true; }
  done
  $SETUP_KIRO && { [ -d "$REPO_ROOT/.kiro/steering" ] && [ "$(find "$REPO_ROOT/.kiro/steering" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')" -gt 0 ] || { err "verify: steering"; fail=true; }; }
  $fail && return 1; return 0; }

detect_legacy() {
  [ -d "$REPO_ROOT/.ai-kit" ] && warn "legacy: .ai-kit/"
  [ -d "$REPO_ROOT/.ai" ] && warn "legacy: .ai/"
  [ -d "$REPO_ROOT/scripts/ai" ] && warn "legacy: scripts/ai/"
  [ -f "$REPO_ROOT/ai-kit.lock" ] && warn "legacy: ai-kit.lock"
  true; }

print_summary() {
  log "=== Summary ==="
  for a in $1; do
    local sc; sc="$(find "$REPO_ROOT/.${a}/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
    local rc; rc="$(find "$REPO_ROOT/.${a}/references" -type f 2>/dev/null | wc -l | tr -d ' ')"
    local st="-"; [ "$a" = "kiro" ] && st="$(find "$REPO_ROOT/.kiro/steering" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
    log "  $a: $sc skills, $rc refs, $st steering"; done; log "complete"; }

main() {
  parse_args "$@"
  [ -d "$REPO_ROOT/.git" ] || { err "not a git repo: $REPO_ROOT"; exit 1; }
  download_kit
  [ -f "$KIT_DIR/tools/lib.sh" ] && source "$KIT_DIR/tools/lib.sh"
  detect_stack "$REPO_ROOT"
  $NO_SETUP && { log "done (--no-setup)"; return 0; }
  show_menu
  $SETUP_KIRO || $SETUP_CODEX || $SETUP_CLAUDE || $SETUP_GEMINI || $SETUP_COPILOT || { warn "no agents"; return 0; }
  local agents=""
  $SETUP_KIRO && agents="$agents kiro"; $SETUP_CODEX && agents="$agents codex"
  $SETUP_CLAUDE && agents="$agents claude"; $SETUP_GEMINI && agents="$agents gemini"
  for a in $agents; do install_skills_for_agent "$a"; install_references_for_agent "$a"; done
  $SETUP_KIRO && install_steering_for_kiro
  generate_agents_md
  $SETUP_CLAUDE && generate_instruction_file "claude" "CLAUDE.md"
  $SETUP_GEMINI && generate_instruction_file "gemini" "GEMINI.md"
  $SETUP_COPILOT && generate_instruction_file "copilot" ".github/copilot-instructions.md"
  run_sync; update_gitignore
  verify_installation "$agents" && print_summary "$agents"
  detect_legacy; }

main "$@"
