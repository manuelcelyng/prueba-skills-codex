#!/usr/bin/env bash
# Initialize a WORKSPACE-level AGENTS.md router (Bash 3.2 compatible).
#
# Usage (from a workspace folder that contains multiple repos):
#   REPO_ROOT="$PWD" ./tools/init-workspace-agents.sh
#   REPO_ROOT="$PWD" AI_SKILLS_PROJECT=smartpay ./tools/init-workspace-agents.sh
#
# Notes:
# - This is optional. It helps when you open Kiro/Codex/Claude/Gemini at the workspace root.
# - It does NOT touch any microservice repo content.
# - No references to .ai-kit/, .ai/skills/, scripts/ai/, or ai-kit.lock.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"

FORCE=false
PROJECT="${AI_SKILLS_PROJECT:-smartpay}"

show_help() {
  cat <<EOF
Usage: $0 [--force] [--project <name>]

Creates/updates (if --force) a workspace-level AGENTS.md at:
  \$REPO_ROOT/AGENTS.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true; shift ;;
    --project) PROJECT="$2"; shift 2 ;;
    --help|-h) show_help; exit 0 ;;
    *)
      echo "Unknown option: $1" 1>&2
      show_help 1>&2
      exit 1
      ;;
  esac
done

agents_file="$REPO_ROOT/AGENTS.md"
if [ -f "$agents_file" ] && ! $FORCE; then
  echo "init-workspace-agents: AGENTS.md already exists: $agents_file"
  exit 0
fi

# Detect repos (git directories inside workspace)
repos_tmp="$(mktemp)"
find "$REPO_ROOT" -maxdepth 2 -name .git -type d -print 2>/dev/null | \
  sed 's/\/\.git$//' | \
  awk -v root="$REPO_ROOT" '{ sub("^" root "/?", "", $0); print }' | \
  LC_ALL=C sort > "$repos_tmp"

newline='
'
repos_list=""
if [ -s "$repos_tmp" ]; then
  while IFS= read -r repo; do
    [ -z "$repo" ] && continue
    repos_list="${repos_list}${newline}- \`${repo}\`"
  done < "$repos_tmp"
else
  repos_list="${newline}- (no repos detectados aún; cloná micros dentro de esta carpeta)"
fi

rm -f "$repos_tmp"

# Detect first available agent skills dir for skill paths
skills_agent=""
for candidate in kiro codex claude gemini; do
  if [ -d "$REPO_ROOT/.${candidate}/skills" ]; then
    skills_agent="$candidate"
    break
  fi
done

# Default to kiro if none found
if [ -z "$skills_agent" ]; then
  skills_agent="kiro"
fi

cat > "$agents_file" <<EOF
# Workspace Guidelines (multi-repo)

Este \`AGENTS.md\` es un **router** para trabajar con múltiples microservicios dentro de este workspace.

## Repos detectados
${repos_list#$newline}

## Cómo trabajar en multi-micro

1) Definí qué microservicios participan (lista explícita).
2) Si trabajás desde este root, usá primero \`smartpay-workspace-router\`.
3) Ejecutá el flujo SDD por repo (uno a la vez o por fases paralelizables).
4) Mantené consistencia de contrato/spec entre micros (mismo \`change-name\` si aplica).

## SDD Quick Start

- Router multi-micro: \`smartpay-workspace-router\`
- Meta-commands / aliases: \`/sdd-init\`, \`/sdd-new <change>\`, \`/sdd-continue\`, \`/sdd-ff <change>\`, \`/sdd-apply\`, \`/sdd-verify\`, \`/sdd-archive\`
- Flujo canónico: \`references/sdd/sdd-playbook.md\`
- Persistencia por micro: un \`openspec/\` por repo, nunca uno global del workspace

## Quick start

- Para cambios multi-micro usá \`smartpay-workspace-router\`.
- Para cambios de un solo micro entrá al repo y usá \`smartpay-sdd-orchestrator\`.

## Available Skills

| Skill | Description | Source |
|------|-------------|--------|
| \`ai-init-agents\` | Genera/mejora el \`AGENTS.md\` real de un repo (micro) basado en análisis del código y build/test. | \`.${skills_agent}/skills/ai-init-agents/SKILL.md\` |
| \`skill-sync\` | Regenera \`### Auto-invoke Skills\` desde metadata de skills. | \`.${skills_agent}/skills/skill-sync/SKILL.md\` |
EOF

if [ "$PROJECT" = "smartpay" ]; then
  cat >> "$agents_file" <<EOF
| \`smartpay-workspace-router\` | Router SmartPay para enrutar cambios multi-micro y coordinar SDD por micro. | \`.${skills_agent}/skills/smartpay-workspace-router/SKILL.md\` |
| \`smartpay-sdd-orchestrator\` | Orquestador delegate-only del flujo SDD por micro. | \`.${skills_agent}/skills/smartpay-sdd-orchestrator/SKILL.md\` |
EOF
fi

cat >> "$agents_file" <<'EOF'

### Auto-invoke Skills

> Esta sección es gestionada por el sync tool (no editar manualmente).
EOF

echo ""
echo "init-workspace-agents: wrote $agents_file"
