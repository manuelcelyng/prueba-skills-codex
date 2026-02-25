---
name: ai-init-agents
description: >
  Genera o mejora el `AGENTS.md` del repo a partir del análisis real del proyecto (stack, estructura, build/test, convenciones).
  Trigger: Usar cuando falte `AGENTS.md`, cuando sea muy pobre, o cuando el repo cambie significativamente y haya que actualizar guías.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Generar/actualizar AGENTS.md"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Crear o actualizar `AGENTS.md` para que sea **útil y específico** al repo, minimizando tokens y ambigüedad para la IA.

## Required Context (load order)

1. Inspeccionar el root del repo: `ls`, `find` (sin recorrer `node_modules/`, `.git/`, `.ai-kit/`, `.ai/`).
2. Identificar stack y build:
   - Java: `gradlew`, `settings.gradle*`, `build.gradle*`, módulos.
   - Python: `pyproject.toml`, `requirements*.txt`, `src/`, `tests/`.
3. Leer documentación existente si existe (en este orden):
   - `README.md`
   - `context/` (solo los archivos relevantes)
   - `docs/` (si existe)
4. Si ya existe `AGENTS.md`, leerlo completo antes de modificarlo.

## Workflow

1. **Diagnóstico**: resumir en 5–10 líneas:
   - stack(s), layout, comandos build/test, patrones (hexagonal/clean), y puntos sensibles (SQL, reactive, error codes).
2. **Si `AGENTS.md` es un stub**, reemplazarlo completamente:
   - Borrar la sección “Regla única (obligatoria)” del stub (era solo onboarding inicial).
   - Mantener una guía permanente en el `AGENTS.md` final (ver punto 3).
3. **Generar/actualizar `AGENTS.md` (token-optimized)**:
   - Mantén el documento **corto y escaneable**: tablas + comandos + reglas clave.
   - Evita pegar reglas extensas: enlaza a skills/references cuando aplique.

### 3.1 Estructura objetivo (estilo Prowler)

El `AGENTS.md` final debe tener, como mínimo:

1) `## Available Skills` con **tablas** (no párrafos largos):

**Tabla 1: Generic Skills (SDD + utilidades)**
- Incluye: `sdd-*`, `ai-init-agents`, `skill-sync`, `skill-creator`, `review`, `ai-setup` (y `agent-unit-tests` si aplica).

**Tabla 2: Project-Specific Skills**
- Si `ai-kit.lock` tiene `AI_SKILLS_PROJECT=smartpay`, incluye `smartpay-*`.

**Tabla 3: Service Skills (overlay local)**
- Skills bajo `./skills/*` del repo (prefijo recomendado: `smartpay-<micro>-<tema>`).

Cada fila debe tener: `Skill | Description | Source`.
El `Source` debe ser un path clickeable dentro del repo, preferiblemente:
- `./.ai/skills/<skill>/SKILL.md`

2) `### Auto-invoke Skills`
- No escribir contenido manualmente; se llena con `./scripts/ai/sync.sh`.

3) Secciones del repo (solo lo que exista / sea real):
- `## Project Structure` (3–8 bullets)
- `## Build / Test / Run` (comandos reales)
- `## Coding Rules` (10–20 bullets máx; lo verdaderamente “no negociable”)
- `## HU / Contracts` (si el repo lo usa)
- `## Maintenance` (reglas para mantener AGENTS actualizado)

### 3.2 Cómo construir las tablas (fuente de verdad)

Regla: construye las tablas desde lo **realmente disponible** en este repo, no desde suposiciones.

Orden recomendado:
1) Si existe `.ai/skills/`: listar skills desde ahí (es la “proyección efectiva”).
2) Si no existe `.ai/skills/`, sugerir correr `./scripts/ai/setup.sh --codex` (o el subset) y luego continuar.
3) Para cada skill, leer solo el frontmatter (name/description) de `SKILL.md` para poblar las tablas.

Clasificación recomendada:
- `Generic`: `sdd-*` + utilidades comunes (`ai-*`, `skill-*`, `review`, `agent-unit-tests`).
- `Project-Specific`: skills con prefijo del proyecto (ej. `smartpay-*`).
- `Service overlay`: skills cuya carpeta fuente resuelve bajo `./skills/`.

### 3.3 “Async” vs “Auto-invoke” (aclaración obligatoria en el AGENTS final)

Incluye una nota breve:
- `auto_invoke` **no** es un watcher ni ejecución en background.
- Es una regla: “para esta acción, invoca primero este skill”.
- “Delegate-only orchestrator” significa que el orquestador **solo coordina** y delega fases a subagents.

4. **No modificar** manualmente `### Auto-invoke Skills`:
   - esa sección la gestiona `./scripts/ai/sync.sh` de forma determinística.
5. Tras actualizar `AGENTS.md`, indicar comandos:
   - `./scripts/ai/setup.sh <flags>` (según el asistente)
   - `./scripts/ai/sync.sh`

## Limits

- No gestionar git, ramas o PRs.
- No inventar reglas: si algo no está en el repo, marcarlo como “pendiente de definir”.
