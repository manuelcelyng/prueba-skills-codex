---
name: skill-creator
description: >
  Crea skills nuevas siguiendo el estándar (frontmatter + metadata + references/assets) y listas para sync/auto-invoke.
  Trigger: Cuando se quiera formalizar un patrón repetible o documentar convenciones específicas para IA.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Crear skills nuevas"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Usa este skill para crear skills nuevas de forma consistente y con progressive disclosure.

## When to create a skill

Crear un skill cuando:
- Hay un patrón que se repite y requiere pasos/guardrails.
- Hay reglas del repo que cambian la “mejor práctica genérica”.

No crear un skill cuando:
- Es un one-off.
- Ya existe documentación local suficiente (mejor crear `references/`).

## Dónde crear el skill

- **Skill reutilizable (para varios servicios):** en `ai-kit/skills/<skill-name>/`
- **Skill exclusiva de un servicio:** en `<servicio>/skills/<servicio>-<skill-name>/`

## Naming

- Core/reusable: `asulado-<tema>` o `<tema>` si es técnico genérico (evitar colisiones).
- Service-only: `<servicio>-<tema>` (ej.: `dispersion-sql-providers`, `novedades-error-codes`).

## Template

Usa `assets/SKILL-TEMPLATE.md` como base.

## Checklist

- `SKILL.md` con frontmatter:
  - `name`, `description`
  - `metadata.scope: [root]`
  - `metadata.auto_invoke: [...]` (acciones que deben disparar el skill)
- Evitar paths absolutos (no `/Users/...`).
- Referencias largas van en `references/` (no inflar `SKILL.md`).
- Si se requieren pasos determinísticos, agregar scripts en `scripts/`.
- Al final, ejecutar `./scripts/ai/sync.sh` para actualizar `AGENTS.md`.
