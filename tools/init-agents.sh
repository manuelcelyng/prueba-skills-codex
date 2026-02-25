#!/usr/bin/env bash
# Initialize a service AGENTS.md if missing (Bash 3.2 compatible).
#
# Usage (from a service repo root):
#   ./.ai-kit/tools/init-agents.sh
#   ./.ai-kit/tools/init-agents.sh --force
#   ./.ai-kit/tools/init-agents.sh --service pagos
#   ./.ai-kit/tools/init-agents.sh --claude
#
# Notes:
# - This script generates a minimal **stub**. The first AI action should be invoking the `ai-init-agents`
#   skill to generate a useful, repo-specific AGENTS.md.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

SERVICE_NAME=""
FORCE=false
SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_CODEX=false
SETUP_COPILOT=false
SETUP_TOUCHED=false

show_help() {
  cat <<EOF
Usage: $0 [--service <name>] [--force] [--all|--claude|--gemini|--codex|--copilot]

Notes:
  - If no assistant flags are provided, defaults to --codex.
  - The chosen flags are only used to print the recommended setup command in the stub.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service) SERVICE_NAME="$2"; shift 2 ;;
    --force) FORCE=true; shift ;;
    --all)
      SETUP_TOUCHED=true
      SETUP_CLAUDE=true
      SETUP_GEMINI=true
      SETUP_CODEX=true
      SETUP_COPILOT=true
      shift
      ;;
    --claude) SETUP_TOUCHED=true; SETUP_CLAUDE=true; shift ;;
    --gemini) SETUP_TOUCHED=true; SETUP_GEMINI=true; shift ;;
    --codex) SETUP_TOUCHED=true; SETUP_CODEX=true; shift ;;
    --copilot) SETUP_TOUCHED=true; SETUP_COPILOT=true; shift ;;
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

normalize_setup_flags() {
  # If user didn't touch selection, default to Codex.
  if [ "$SETUP_TOUCHED" = false ] && ! $SETUP_CLAUDE && ! $SETUP_GEMINI && ! $SETUP_CODEX && ! $SETUP_COPILOT; then
    SETUP_CODEX=true
  fi

  # If all selected, use --all.
  if $SETUP_CLAUDE && $SETUP_GEMINI && $SETUP_CODEX && $SETUP_COPILOT; then
    echo "--all"
    return 0
  fi

  out=""
  $SETUP_CLAUDE && out="$out --claude"
  $SETUP_GEMINI && out="$out --gemini"
  $SETUP_CODEX && out="$out --codex"
  $SETUP_COPILOT && out="$out --copilot"

  out="$(echo "$out" | sed 's/^[[:space:]]*//')"
  if [ -z "$out" ]; then
    out="--codex"
  fi
  echo "$out"
}

setup_flags="$(normalize_setup_flags)"

cat > "$agents_file" <<EOF
# Repository Guidelines

Este documento guía contribuciones en el servicio \`$SERVICE_NAME\`.

## Regla única (obligatoria)

Antes de iniciar cualquier tarea, invoca el skill \`ai-init-agents\` para generar/mejorar este \`AGENTS.md\` en base al análisis real del repo.

## Comandos (según tu asistente)

- Setup: \`./scripts/ai/setup.sh $setup_flags\`
- Sync: \`./scripts/ai/sync.sh\`

> Nota: La sección \`### Auto-invoke Skills\` la gestiona \`./scripts/ai/sync.sh\` (no editar manualmente).
EOF

echo ""
echo "init-agents: created $agents_file"
