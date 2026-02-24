---
name: skill-creator
description: Crea skills nuevas siguiendo el estándar (frontmatter + metadata + references/assets) y listas para sync/auto-invoke.
metadata:
  scope: root
  auto_invoke:
    - "Crear skills nuevas"
---

# Skill Creator (ASULADO)

Usa este skill para crear skills nuevas de forma consistente y con progressive disclosure.

## Dónde crear el skill

- **Skill reutilizable (para varios servicios):** en `ai-kit/skills/<skill-name>/`
- **Skill exclusiva de un servicio:** en `<servicio>/skills/<servicio>-<skill-name>/`

## Naming

- Core/reusable: `asulado-<tema>` o `<tema>` si es técnico genérico (evitar colisiones).
- Service-only: `<servicio>-<tema>` (ej.: `dispersion-sql-providers`, `novedades-error-codes`).

## Plantilla

Usa `assets/SKILL-TEMPLATE.md` como base.

## Checklist obligatorio

- `SKILL.md` con frontmatter:
  - `name`, `description`
  - `metadata.scope: root`
  - `metadata.auto_invoke: [...]` (acciones que deben disparar el skill)
- Evitar paths absolutos (no `/Users/...`).
- Referencias largas van en `references/` (no inflar `SKILL.md`).
- Si se requieren pasos determinísticos, agregar scripts en `scripts/`.
- Al final, ejecutar `./scripts/ai/sync.sh` para actualizar `AGENTS.md`.
