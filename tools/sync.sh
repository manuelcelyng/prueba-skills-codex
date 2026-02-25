#!/usr/bin/env bash
# Sync skill metadata to AGENTS.md "Auto-invoke Skills" sections (Bash 3.2 compatible).
#
# Reads from: .ai/skills/*/SKILL.md
# Writes to: AGENTS.md (scope=root) or <scope>/AGENTS.md
#
# Usage:
#   .ai-kit/tools/sync.sh [--dry-run] [--scope <scope>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
SKILLS_DIR="$REPO_ROOT/.ai/skills"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DRY_RUN=false
FILTER_SCOPE=""
PROJECT="${AI_SKILLS_PROJECT:-}"

LOCK_FILE="$REPO_ROOT/ai-kit.lock"
if [ -f "$LOCK_FILE" ]; then
  # Optional: project-level filtering (e.g., smartpay vs asulado).
  # shellcheck disable=SC1090
  source "$LOCK_FILE"
  PROJECT="${AI_SKILLS_PROJECT:-$PROJECT}"
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    --scope) FILTER_SCOPE="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: $0 [--dry-run] [--scope <scope>]"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

get_agents_path() {
  local scope="$1"
  if [ "$scope" = "root" ]; then
    echo "$REPO_ROOT/AGENTS.md"
  else
    echo "$REPO_ROOT/$scope/AGENTS.md"
  fi
}

extract_field() {
  local file="$1"
  local field="$2"
  awk -v field="$field" '
    /^---$/ { in_frontmatter = !in_frontmatter; next }
    in_frontmatter && $1 == field":" {
      sub(/^[^:]+:[[:space:]]*/, "")
      if ($0 != "" && $0 != ">") {
        gsub(/^["'\'']|["'\'']$/, "")
        print
        exit
      }
      getline
      while (/^[[:space:]]/ && !/^---$/) {
        sub(/^[[:space:]]+/, "")
        printf "%s ", $0
        if (!getline) break
      }
      print ""
      exit
    }
  ' "$file" | sed 's/[[:space:]]*$//'
}

extract_metadata() {
  local file="$1"
  local field="$2"

  awk -v field="$field" '
    function trim(s) {
      sub(/^[[:space:]]+/, "", s)
      sub(/[[:space:]]+$/, "", s)
      return s
    }
    /^---$/ { in_frontmatter = !in_frontmatter; next }
    in_frontmatter && /^metadata:/ { in_metadata = 1; next }
    in_frontmatter && in_metadata && /^[a-z]/ && !/^[[:space:]]/ { in_metadata = 0 }
    in_frontmatter && in_metadata && $1 == field":" {
      sub(/^[^:]+:[[:space:]]*/, "")
      if ($0 != "") {
        v = $0
        gsub(/^["'\'']|["'\'']$/, "", v)
        gsub(/^\[|\]$/, "", v)
        print trim(v)
        exit
      }
      out = ""
      while (getline) {
        if ($0 ~ /^---$/) break
        if ($0 ~ /^[a-z]/ && $0 !~ /^[[:space:]]/) break
        line = $0
        if (line ~ /^[[:space:]]*-[[:space:]]*/) {
          sub(/^[[:space:]]*-[[:space:]]*/, "", line)
          line = trim(line)
          gsub(/^["'\'']|["'\'']$/, "", line)
          if (line != "") {
            if (out == "") out = line
            else out = out "|" line
          }
        } else {
          break
        }
      }
      if (out != "") print out
      exit
    }
  ' "$file"
}

if [ ! -d "$SKILLS_DIR" ]; then
  echo -e "${RED}Missing $SKILLS_DIR.${NC}"
  echo -e "${YELLOW}Service repo:${NC} run ./scripts/ai/setup.sh --codex (or --all) then retry."
  echo -e "${YELLOW}Workspace root:${NC} run ./workspace-ai.sh --init-agents --codex (or --all) then retry."
  exit 1
fi

rows_file="$(mktemp)"
missing_file="$(mktemp)"

while IFS= read -r skill_file; do
  [ -f "$skill_file" ] || continue

  skill_name="$(extract_field "$skill_file" "name")"
  scope_raw="$(extract_metadata "$skill_file" "scope")"
  auto_raw="$(extract_metadata "$skill_file" "auto_invoke")"

  if [ -z "$skill_name" ]; then
    skill_name="$(basename "$(dirname "$skill_file")")"
  fi

  # Keep the auto-invoke table intentionally small for SmartPay.
  # Sub-agents (`sdd-*`) are invoked by the orchestrator and should not flood the table.
  if [ "$PROJECT" = "smartpay" ]; then
    case "$skill_name" in
      ai-init-agents|skill-sync|ai-setup|smartpay-sdd-orchestrator|smartpay-workspace-router) ;;
      *) continue ;;
    esac
  fi

  # Only skills with metadata.auto_invoke participate in sync output.
  # Skills without auto_invoke are intentionally ignored (e.g., sub-agents invoked by an orchestrator).
  if [ -z "$auto_raw" ]; then
    continue
  fi

  # auto_invoke without scope is a configuration error (we don't know which AGENTS.md to update).
  if [ -z "$scope_raw" ]; then
    echo "$skill_name" >> "$missing_file"
    continue
  fi

  # scope can be "root" or "ui, api" etc.
  # Split on comma and space.
  scope_raw="$(echo "$scope_raw" | tr ',' ' ')"
  for scope in $scope_raw; do
    scope="$(echo "$scope" | tr -d '[:space:]')"
    [ -z "$scope" ] && continue

    [ -n "$FILTER_SCOPE" ] && [ "$scope" != "$FILTER_SCOPE" ] && continue

    auto_list="$(echo "$auto_raw" | tr '|' '\n')"
    echo "$auto_list" | while IFS= read -r action; do
      action="$(echo "$action" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
      [ -z "$action" ] && continue
      printf "%s\t%s\t%s\n" "$scope" "$action" "$skill_name" >> "$rows_file"
    done
  done
# Note: .ai/skills contains symlinks to skill directories; BSD find does not
# traverse symlinked directories unless -L is used.
done < <(find -L "$SKILLS_DIR" -mindepth 2 -maxdepth 2 -name SKILL.md -print | sort)

sorted_file="$(mktemp)"
LC_ALL=C sort -t $'\t' -k1,1 -k2,2 -k3,3 "$rows_file" > "$sorted_file"

echo -e "${BLUE}Skill Sync - Updating AGENTS.md Auto-invoke sections${NC}"
echo "========================================================"
echo ""

cut -f1 "$sorted_file" | LC_ALL=C sort -u | while IFS= read -r scope; do
  [ -z "$scope" ] && continue
  agents_path="$(get_agents_path "$scope")"

  if [ ! -f "$agents_path" ]; then
    echo -e "${YELLOW}Warning: No AGENTS.md found for scope '$scope' ($agents_path)${NC}"
    continue
  fi

  echo -e "${BLUE}Processing: $scope -> $agents_path${NC}"

  auto_invoke_section="### Auto-invoke Skills

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|"

  while IFS=$'\t' read -r action skill; do
    [ -z "$action" ] && continue
    auto_invoke_section="$auto_invoke_section
| $action | \`$skill\` |"
  done < <(
    awk -F'\t' -v scope="$scope" '$1==scope {print $2 "\t" $3}' "$sorted_file" | \
      LC_ALL=C sort -t $'\t' -k1,1 -k2,2
  )

  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY RUN] Would update $agents_path with:${NC}"
    echo "$auto_invoke_section"
    echo ""
    continue
  fi

  section_file="$(mktemp)"
  echo "$auto_invoke_section" > "$section_file"

  if grep -q "^### Auto-invoke Skills" "$agents_path"; then
    awk '
      /^### Auto-invoke Skills/ {
        while ((getline line < "'"$section_file"'") > 0) print line
        close("'"$section_file"'")
        skip = 1
        next
      }
      skip && /^(---|## )/ {
        skip = 0
        print ""
      }
      !skip { print }
    ' "$agents_path" > "$agents_path.tmp"
    mv "$agents_path.tmp" "$agents_path"
    echo -e "${GREEN}  ✓ Updated Auto-invoke section${NC}"
  else
    echo "" >> "$agents_path"
    echo "$auto_invoke_section" >> "$agents_path"
    echo -e "${GREEN}  ✓ Appended Auto-invoke section${NC}"
  fi

  rm -f "$section_file"
done

echo ""
echo -e "${GREEN}Done!${NC}"

missing_count="$(wc -l < "$missing_file" | tr -d '[:space:]')"
if [ "$missing_count" != "0" ]; then
  echo ""
  echo -e "${BLUE}Skills missing sync metadata:${NC}"
  sort "$missing_file" | uniq | sed 's/^/  - /'
fi

rm -f "$rows_file" "$missing_file" "$sorted_file"
