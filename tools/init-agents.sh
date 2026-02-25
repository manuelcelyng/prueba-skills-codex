#!/usr/bin/env bash
# Initialize a service AGENTS.md if missing (Bash 3.2 compatible).
#
# Usage (from a service repo root):
#   ./.ai-kit/tools/init-agents.sh
#   ./.ai-kit/tools/init-agents.sh --force
#   ./.ai-kit/tools/init-agents.sh --service pagos
#
# Notes:
# - This script is intentionally minimal; service-specific rules should live in skills or existing docs.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

SERVICE_NAME=""
FORCE=false

show_help() {
  echo "Usage: $0 [--service <name>] [--force]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service) SERVICE_NAME="$2"; shift 2 ;;
    --force) FORCE=true; shift ;;
    --help|-h) show_help; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      show_help >&2
      exit 1
      ;;
  esac
done

if [ -z "$SERVICE_NAME" ]; then
  SERVICE_NAME="$(basename "$REPO_ROOT")"
fi

agents_file="$REPO_ROOT/AGENTS.md"

if [ -f "$agents_file" ] && ! $FORCE; then
  echo "init-agents: AGENTS.md already exists: $agents_file"
  exit 0
fi

is_java=false
is_python=false
if [ -f "$REPO_ROOT/gradlew" ] || [ -f "$REPO_ROOT/build.gradle" ] || [ -f "$REPO_ROOT/build.gradle.kts" ] || [ -f "$REPO_ROOT/settings.gradle" ] || [ -f "$REPO_ROOT/settings.gradle.kts" ]; then
  is_java=true
fi
if [ -f "$REPO_ROOT/pyproject.toml" ] || [ -f "$REPO_ROOT/requirements.txt" ] || [ -f "$REPO_ROOT/requirements-dev.txt" ] || [ -f "$REPO_ROOT/template.yaml" ]; then
  is_python=true
fi

stack_line=""
if $is_java && $is_python; then
  stack_line="Stack: Java + Python (mixed)."
elif $is_java; then
  stack_line="Stack: Java."
elif $is_python; then
  stack_line="Stack: Python."
else
  stack_line="Stack: (por definir)."
fi

cat > "$agents_file" <<EOF
# Repository Guidelines

Este documento guía contribuciones en el servicio \`$SERVICE_NAME\`.

$stack_line

## AI Skills

- Configurar herramientas IA (Codex/Claude/Gemini/Copilot): \`./scripts/ai/setup.sh --all\`
- Sincronizar tabla Auto-invoke: \`./scripts/ai/sync.sh\`
- Crear \`AGENTS.md\` (si falta): \`./scripts/ai/init-agents.sh\`
- Skills del micro (si existen): \`skills/\`
- Skills core (vendor): \`.ai-kit/skills/\` (se proyectan a \`.ai/skills/\`)

## Project Structure

- HUs (contratos/planes): \`context/hu/\` (si aplica).
- Reglas comunes (kit): \`.ai-kit/references/\` (playbook, reglas, plantillas).

## Build & Test (si aplica)

EOF

if $is_java; then
  cat >> "$agents_file" <<'EOF'
- `./gradlew clean build`
- `./gradlew test`
EOF
fi

if $is_python; then
  cat >> "$agents_file" <<'EOF'
- `python -m venv venv && source venv/bin/activate`
- `pip install -r requirements.txt`
- `pytest`
EOF
fi

echo ""
echo "init-agents: created $agents_file"

