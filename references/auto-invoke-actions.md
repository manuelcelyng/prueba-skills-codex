# Auto-invoke y scope (AI Kit)

Este documento define cómo usar `metadata.scope` y `metadata.auto_invoke` en `SKILL.md` para que:

- `./scripts/ai/sync.sh` genere la tabla `### Auto-invoke Skills` en `AGENTS.md`.
- La IA tenga señales claras y consistentes para cargar skills con menos ruido.

## Qué es `metadata.scope`

`scope` define **en qué `AGENTS.md`** se publica la tabla de auto-invoke para ese skill.

Reglas (según `ai-kit/tools/sync.sh`):
- `scope: [root]` actualiza `./AGENTS.md` (en el root del repo del servicio).
- `scope: [<path>]` actualiza `./<path>/AGENTS.md` (solo si existe ese archivo).
- Se permiten múltiples scopes: `scope: [root, api]`.

En SmartPay (modelo multi-repo), casi siempre es:
- `scope: [root]`

## Qué es `metadata.auto_invoke`

`auto_invoke` es una lista de **acciones** (strings) que se publican como fila en la tabla:

| Action | Skill |
|--------|-------|
| <acción> | `<skill-name>` |

No es “ejecución automática” del runtime: es una **regla declarativa** que ayuda a la IA a:
- detectar rápidamente qué skill cargar según la tarea,
- y mantener consistencia entre herramientas.

## Catálogo recomendado de Actions (estables)

Usa estas acciones tal cual para evitar drift:
- `Planificar HU / contrato` → `planning-java` / `planning-python`
- `Implementar cambios` → `dev-java` / `dev-python`
- `Escribir/actualizar unit tests` → `agent-unit-tests`
- `Revisar cambios` → `review`
- `Revisar MR Java en GitLab` → `gitlab-mr-review-java`
- `Revisar MR Python en GitLab` → `gitlab-mr-review-python`
- `Crear skills nuevas` → `skill-creator`
- `Generar/actualizar AGENTS.md` → `ai-init-agents`
- `Iniciar SDD (SmartPay)` → `smartpay-sdd-orchestrator`
- `Enrutar cambios multi-micro (SmartPay)` → `smartpay-workspace-router`
- `Configurar herramientas IA` → `ai-setup`
- `Regenerar auto-invoke (sync)` → `skill-sync`
- `Después de crear/modificar un skill` → `skill-sync`
- `Coordinar planning multi-stack` → `planning`
- `Coordinar implementación multi-stack` → `dev`
- `Definir / actualizar error codes` → `<servicio>-error-codes`

## Dónde vive la guía SDD

- `.ai-kit/references/sdd/sdd-playbook.md`
- `.ai-kit/references/hu-context-template.md`

## Convenciones

1) **Acciones cortas y consistentes**
- Preferir infinitivo: “Planificar…”, “Implementar…”, “Revisar…”.

2) **Evitar acciones duplicadas**
- Si `dev-java` tiene `Implementar cambios`, evita poner la misma acción en `dev`.
- Los coordinadores (`dev`, `planning`) deben tener acciones distintas (multi-stack).

3) **Skills específicas de un micro (SmartPay)**
- Nombre recomendado: `smartpay-<micro>-<tema>`.
- `scope: [root]`.
- `auto_invoke`: usar acción específica y estable.
