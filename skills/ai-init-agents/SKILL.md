---
name: ai-init-agents
description: >
  Genera o mejora el `AGENTS.md` del repo a partir del análisis real del proyecto (stack, estructura, build/test, convenciones).
  Trigger: Usar cuando falte `AGENTS.md`, cuando sea muy pobre, o cuando el repo cambie significativamente y haya que actualizar guías.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.3"
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

1. **Diagnóstico**: resumir en 5–10 líneas stack, layout, build/test, patrones y puntos sensibles.
2. **Si `AGENTS.md` es un stub**, reemplazarlo completamente.
3. **Generar/actualizar `AGENTS.md` (token-optimized)**:
   - corto y escaneable,
   - tablas para skills,
   - comandos reales,
   - reglas no negociables,
   - quick start SDD.

### Estructura objetivo

1) `## Available Skills` con tablas:
- Generic Skills (`sdd-*`, `ai-*`, `skill-*`, `review`, `agent-unit-tests` si aplica)
- Project-Specific Skills (`smartpay-*`)
- Service Skills (`./skills/*`)

2) `### Auto-invoke Skills`
- no escribirla manualmente; la llena `./scripts/ai/sync.sh`

3) Secciones funcionales reales del repo:
- `## Project Structure`
- `## Build / Test / Run`
- `## Coding Rules`
- `## HU / Contracts` (si aplica)
- `## SDD Quick Start`
- `## Maintenance`

### Nota obligatoria sobre SDD

El `AGENTS.md` final debe dejar explícito:
- entrypoint por micro: `smartpay-sdd-orchestrator`
- entrypoint por workspace: `smartpay-workspace-router`
- aliases del flujo: `/sdd-init`, `/sdd-new <change>`, `/sdd-continue`, `/sdd-ff`, `/sdd-apply`, `/sdd-verify`, `/sdd-archive`
- fuente de verdad del flujo: `references/sdd/sdd-playbook.md`
- `delegate-only orchestrator` = coordina y delega fases; no hace el trabajo de fase directamente
- las reglas de implementación viven en `dev-java` / `dev-python`
- las reglas de auditoría viven en `review`
- `auto_invoke` no es watcher ni ejecución en background

## Limits

- No gestionar git, ramas o PRs.
- No inventar reglas: si algo no está en el repo, marcarlo como “pendiente de definir”.
