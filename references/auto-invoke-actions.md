# Auto-invoke y scope (AI Kit)

Este documento define cómo usar `metadata.scope` y `metadata.auto_invoke` en `SKILL.md` para que:

- `./scripts/ai/sync.sh` genere la tabla `### Auto-invoke Skills` en `AGENTS.md`.
- La IA (router) tenga señales claras y consistentes para cargar skills con menos tokens.

## Qué es `metadata.scope`

`scope` define **en qué `AGENTS.md`** se publica la tabla de auto-invoke para ese skill.

Reglas (según `ai-kit/tools/sync.sh`):
- `scope: [root]` actualiza `./AGENTS.md` (en el root del repo del servicio).
- `scope: [<path>]` actualiza `./<path>/AGENTS.md` (solo si existe ese archivo).
- Se permiten múltiples scopes: `scope: [root, api]` (monorepos).

En ASULADO (modelo multi-repo), casi siempre es:
- `scope: [root]`

## Qué es `metadata.auto_invoke`

`auto_invoke` es una lista de **acciones** (strings) que se publican como fila en la tabla:

| Action | Skill |
|--------|-------|
| <acción> | `<skill-name>` |

No es “ejecución automática” del runtime: es una **regla declarativa** que ayuda a la IA a:
- detectar rápidamente qué skill cargar según la tarea,
- y mantener consistencia entre herramientas (Codex/Claude/Gemini/Copilot).

## Catálogo recomendado de Actions (estables)

Usa estas acciones tal cual para evitar drift:

- `Enrutar tarea (orquestador)` → `asulado-router`
- `Planificar HU / contrato` → `planning-java` / `planning-python`
- `Implementar cambios` → `dev-java` / `dev-python`
- `Escribir/actualizar unit tests` → `agent-unit-tests`
- `Revisar cambios` → `review`
- `Crear skills nuevas` → `skill-creator`
- `Generar/actualizar AGENTS.md` → `ai-init-agents`
- `Configurar herramientas IA` → `ai-setup`
- `Regenerar auto-invoke (sync)` → `skill-sync`
- `Después de crear/modificar un skill` → `skill-sync`
- `Coordinar planning multi-stack` → `planning`
- `Coordinar implementación multi-stack` → `dev`
- `Definir / actualizar error codes` → `<servicio>-error-codes` (skills locales)

## Dónde vive la guía HU

- `.ai-kit/references/hu-prompts-and-template-usage.md`
- `.ai-kit/references/hu-context-template.md`

## Convenciones

1) **Acciones cortas y consistentes**
- Preferir infinitivo: “Planificar…”, “Implementar…”, “Revisar…”.

2) **Evitar acciones duplicadas**
- Si `dev-java` tiene `Implementar cambios`, evita poner la misma acción en `dev`.
- Los coordinadores (`dev`, `planning`) deben tener acciones distintas (multi-stack).

3) **Skills específicas de un micro**
- Nombre recomendado: `<servicio>-<tema>` (ej. `dispersion-sql-providers`).
- `scope: [root]` (porque el repo del micro tiene su `AGENTS.md` en root).
- `auto_invoke`: usar acción específica y estable (ej. `Modificar SQL Providers`), pero primero valida si ya existe una acción genérica que cubra el caso.

## Ejemplos

### Skill core (reusable)
```yaml
---
name: dev-java
description: >
  Implementa cambios en servicios Java (Spring Boot WebFlux/R2DBC).
  Trigger: Cuando el usuario pida implementar/fix/refactor o agregar endpoints en un servicio Java.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Implementar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---
```

### Skill de catálogo de error codes (micro)
```yaml
---
name: dispersion-error-codes
description: >
  Catálogo y reglas de ErrorCodes del micro Dispersión.
  Trigger: Cuando se cree/edite un ErrorCode o se defina el mapeo HTTP/mensaje del contrato.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Definir / actualizar error codes"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---
```

### Skill exclusiva de `dispersion`
```yaml
---
name: dispersion-sql-providers
description: >
  Reglas y patrones específicos para SQL Providers en Dispersión.
  Trigger: Cuando se modifique/cree un SQL Provider en Dispersión.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Modificar SQL Providers"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---
```
