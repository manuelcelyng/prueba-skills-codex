#!/usr/bin/env bash
# Initialize a service AGENTS.md if missing (Bash 3.2 compatible).
#
# Usage (from a service repo root):
#   ./tools/init-agents.sh
#   ./tools/init-agents.sh --force
#   ./tools/init-agents.sh --service pagos
#   ./tools/init-agents.sh --claude
#
# Notes:
# - This script generates a minimal **stub**. The first AI action should be
#   invoking the `ai-init-agents` skill to generate a useful, repo-specific
#   AGENTS.md.
# - No references to .ai-kit/, scripts/ai/, or ai-kit.lock.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"

SERVICE_NAME=""
FORCE=false
SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_CODEX=false
SETUP_COPILOT=false
SETUP_KIRO=false

show_help() {
  cat <<EOF
Usage: $0 [--service <name>] [--force] [--all|--kiro|--claude|--gemini|--codex|--copilot]

Notes:
  - If no assistant flags are provided, defaults to --kiro.
  - Agent flags are accepted for compatibility but do not change the stub content.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service) SERVICE_NAME="$2"; shift 2 ;;
    --force) FORCE=true; shift ;;
    --all)
      SETUP_KIRO=true
      SETUP_CLAUDE=true
      SETUP_GEMINI=true
      SETUP_CODEX=true
      SETUP_COPILOT=true
      shift
      ;;
    --kiro)    SETUP_KIRO=true;    shift ;;
    --claude)  SETUP_CLAUDE=true;  shift ;;
    --gemini)  SETUP_GEMINI=true;  shift ;;
    --codex)   SETUP_CODEX=true;   shift ;;
    --copilot) SETUP_COPILOT=true; shift ;;
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

cat > "$agents_file" <<EOF
# Repository Guidelines

Este documento guía contribuciones en el servicio \`$SERVICE_NAME\`.

## Regla única (obligatoria)

En el **primer contacto** con este repo, invocá el skill \`ai-init-agents\` **inmediatamente** (sin pedir confirmación) para **reemplazar este stub** por un \`AGENTS.md\` completo basado en el análisis real del repo.

## SDD Quick Start

- Para cambios no triviales en este micro usá \`smartpay-sdd-orchestrator\`.
- Reconocé como aliases del flujo: \`/sdd-init\`, \`/sdd-new <change>\`, \`/sdd-continue\`, \`/sdd-ff <change>\`, \`/sdd-apply\`, \`/sdd-verify\`, \`/sdd-archive\`.
- Los artefactos SDD viven en \`openspec/changes/<change-name>/\` cuando el artifact store es \`openspec\`.
- Las reglas del flujo viven en \`references/sdd/sdd-playbook.md\`.

> Nota: La sección \`### Auto-invoke Skills\` la gestiona el sync tool (no editar manualmente).
> Después del primer generado, \`ai-init-agents\` debe borrar esta "Regla única" y dejar una guía permanente.
EOF

echo ""
echo "init-agents: created $agents_file"
