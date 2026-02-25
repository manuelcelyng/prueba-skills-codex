#!/usr/bin/env bash
# Create a new skill scaffold (Bash 3.2 compatible).
#
# Usage (from a service repo):
#   .ai-kit/tools/create-skill.sh --where ./skills --name dispersion-foo --auto "Definir / actualizar error codes"
#
# Usage (create core skill in ai-kit):
#   ./tools/create-skill.sh --where ./skills --name asulado-foo --auto "Acción"

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_TEMPLATE="$SCRIPT_DIR/../assets/SKILL-TEMPLATE.md"

WHERE=""
NAME=""
SCOPE="root"
AUTHOR="${AI_SKILL_AUTHOR:-pragma-asulado}"
VERSION="${AI_SKILL_VERSION:-0.1}"
AUTO_ACTIONS=()
TEMPLATE="$DEFAULT_TEMPLATE"

usage() {
  cat <<EOF
Usage:
  $0 --where <skills-dir> --name <skill-name> [--scope root] [--auto "<Action>"]... [--template <file>]

Notes:
  - --auto can be provided multiple times to add multiple actions.
  - If no --auto is provided, the skill will NOT appear in Auto-invoke table until you add metadata.auto_invoke.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --where) WHERE="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --scope) SCOPE="$2"; shift 2 ;;
    --auto) AUTO_ACTIONS+=("$2"); shift 2 ;;
    --template) TEMPLATE="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$WHERE" ] || [ -z "$NAME" ]; then
  usage >&2
  exit 1
fi

if [ ! -f "$TEMPLATE" ]; then
  echo "Missing template: $TEMPLATE" >&2
  exit 1
fi

skill_dir="$WHERE/$NAME"
skill_file="$skill_dir/SKILL.md"

mkdir -p "$skill_dir"
if [ -f "$skill_file" ]; then
  echo "Already exists: $skill_file" >&2
  exit 1
fi

yaml_escape() {
  # Minimal escaping for double quotes; keep it simple for our action strings.
  echo "$1" | sed 's/"/\\"/g'
}

auto_lines=""
if [ ${#AUTO_ACTIONS[@]} -gt 0 ]; then
  for a in "${AUTO_ACTIONS[@]}"; do
    a_esc="$(yaml_escape "$a")"
    auto_lines="${auto_lines}    - \"${a_esc}\"\n"
  done
else
  auto_lines="    - \"<Acción estable 1>\"\n"
fi

cat > "$skill_file" <<EOF
---
name: $NAME
description: >
  <1-2 líneas: qué hace y para quién>.
  Trigger: <cuándo se debe invocar>.
license: Internal
metadata:
  author: $AUTHOR
  version: "$VERSION"
  scope: [$SCOPE]
  auto_invoke:
$(printf "%b" "$auto_lines")
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

<Qué problema resuelve este skill y qué resultados produce.>

## Required Context (load order)
1. Leer \`AGENTS.md\`.
2. Leer \`.ai-kit/references/context-readme.md\`.
3. Cargar solo los contextos/HUs que apliquen.

## Workflow

- <Paso 1>
- <Paso 2>
- <Paso 3>

## Limits

- No gestionar git, ramas o PRs.
EOF

echo "Created: $skill_file"
echo "Next:"
echo "  - ./scripts/ai/setup.sh --all"
echo "  - ./scripts/ai/sync.sh"
