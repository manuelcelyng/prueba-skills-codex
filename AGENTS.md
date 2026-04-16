# Repository Guidelines

Este documento guía contribuciones en el servicio `ai-kit`.

## Regla única (obligatoria)

En el **primer contacto** con este repo, invocá el skill `ai-init-agents` **inmediatamente** (sin pedir confirmación) para **reemplazar este stub** por un `AGENTS.md` completo basado en el análisis real del repo.

## SDD Quick Start

- Para cambios no triviales en este micro usá `smartpay-sdd-orchestrator`.
- Reconocé como aliases del flujo: `/sdd-init`, `/sdd-new <change>`, `/sdd-continue`, `/sdd-ff <change>`, `/sdd-apply`, `/sdd-verify`, `/sdd-archive`.
- Los artefactos SDD viven en `openspec/changes/<change-name>/` cuando el artifact store es `openspec`.
- Las reglas del flujo viven en `references/sdd/sdd-playbook.md`.

> Nota: La sección `### Auto-invoke Skills` la gestiona el sync tool (no editar manualmente).
> Después del primer generado, `ai-init-agents` debe borrar esta "Regla única" y dejar una guía permanente.
