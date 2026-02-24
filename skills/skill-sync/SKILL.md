---
name: skill-sync
description: >
  Regenera la sección "Auto-invoke Skills" en AGENTS.md a partir de metadata en SKILL.md.
  Trigger: Después de crear/modificar un skill o cuando la tabla de Auto-invoke esté desactualizada.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Regenerar auto-invoke (sync)"
    - "Después de crear/modificar un skill"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Este skill mantiene `AGENTS.md` sincronizado con las skills disponibles, generando una tabla determinística:

- Sección: `### Auto-invoke Skills`
- Fuente: `metadata.scope` + `metadata.auto_invoke` en cada `SKILL.md`

## Usage

En el repo del servicio:
- Ejecutar `./scripts/ai/sync.sh`

## Rules

- Nunca edites manualmente la tabla “Auto-invoke Skills”; se sobreescribe en cada sync.
- Si un skill no aparece en la tabla, verifica que su `SKILL.md` tenga:
  - `metadata.scope: [root]` (o un subpath válido)
  - `metadata.auto_invoke:` con al menos una acción
