---
name: ai-init-agents
description: >
  Genera o mejora el `AGENTS.md` del repo a partir del análisis real del proyecto (stack, estructura, build/test, convenciones).
  Trigger: Usar cuando falte `AGENTS.md`, cuando sea muy pobre, o cuando el repo cambie significativamente y haya que actualizar guías.
license: Internal
metadata:
  author: pragma-asulado
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
3. **Generar/actualizar `AGENTS.md`** con secciones mínimas (ajustar al repo real):
   - Project Structure
   - Build/Test/Run
   - Coding rules (las que el repo realmente aplica)
   - Convenciones de HU/contratos (si el repo las usa)
   - AI kit: ubicación de skills y cómo mantener `Auto-invoke`
   - **Mantenimiento de `AGENTS.md` (obligatorio)**:
     - Si detectas señales fuertes de desactualización (nuevo stack/módulos, cambios de build/test, nuevas reglas relevantes, cambios grandes de arquitectura), **sugiere** ejecutar `ai-init-agents`.
     - Solo ejecuta `ai-init-agents` si el usuario lo pide o lo aprueba explícitamente.
4. **No modificar** manualmente la sección `### Auto-invoke Skills`:
   - esa sección la gestiona `./scripts/ai/sync.sh` de forma determinística.
5. Indicar los comandos a ejecutar tras actualizar `AGENTS.md`:
   - `./scripts/ai/setup.sh --codex` (o el subset que use el developer)
   - `./scripts/ai/sync.sh`

## Limits

- No gestionar git, ramas o PRs.
- No inventar reglas: si algo no está en el repo, marcarlo como “pendiente de definir”.
