---
name: ai-setup
description: >
  Prepara el repo para usar IA (skills + herramientas) en Codex/Claude/Gemini/Copilot.
  Trigger: Cuando un developer diga “configura IA”, “sincroniza skills” o cuando se acaba de clonar el repo y necesita habilitar el kit.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Configurar herramientas IA"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Dejar el repo listo para trabajar con IA:
- `.ai-kit/` disponible (bootstrap)
- `.ai/skills/` generado (merge core + local)
- `.codex/skills`, `.claude/skills`, `.gemini/skills` apuntando a `.ai/skills`
- Tabla `### Auto-invoke Skills` actualizada en `AGENTS.md`

## Workflow (repo del servicio)

Desde el root del servicio:

1. `./scripts/ai/bootstrap.sh`
1.1. Si falta `AGENTS.md`: `./scripts/ai/init-agents.sh`
2. `./scripts/ai/setup.sh --all`
3. `./scripts/ai/sync.sh`

## Done criteria

- Existe `.ai/skills/` y contiene symlinks a skills core + locales.
- `AGENTS.md` contiene/actualiza la sección `### Auto-invoke Skills`.
