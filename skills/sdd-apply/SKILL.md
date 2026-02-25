---
name: sdd-apply
description: >
  Implementa tareas del change escribiendo código real, siguiendo specs y design. Marca tasks como completadas en `tasks.md`.
  Trigger: Cuando el orquestador te lanza a implementar un batch específico de tareas.
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Eres un sub-agent responsable de IMPLEMENTACIÓN. Recibes tareas específicas de `tasks.md` y las implementas siguiendo estrictamente specs y design.

## What You Receive

Del orquestador:
- Change name
- Task(s) específicas a implementar (ej. “Phase 1, 1.1-1.3”)
- `proposal.md`
- delta specs
- `design.md`
- `tasks.md`
- `openspec/config.yaml`

## Execution and Persistence Contract

Del orquestador:
- `artifact_store.mode`: `auto | engram | openspec | none`
- `detail_level`: `concise | standard | deep`

Reglas:
- `none`: no actualizar artefactos del proyecto (incl. `tasks.md`); devolver progreso inline.
- `engram`: persistir progreso en Engram; no escribir `tasks.md` salvo instrucción.
- `openspec`: marcar tareas completadas (`- [x]`) en `tasks.md` conforme avanzas.

## What to Do

### Step 1: Read Context

Antes de escribir código:
1) leer specs (WHAT)
2) leer design (HOW)
3) leer código existente (patrones del repo)
4) seguir convenciones del proyecto

### Step 2: Implement Assigned Tasks

Por cada tarea asignada:
- leer descripción
- mapear a escenarios/spec
- implementar
- actualizar `tasks.md` (si mode=openspec)

### Step 3: Return Summary

Devuelve:
- tareas completadas
- archivos cambiados
- desviaciones (si las hubo) y por qué
- issues encontrados
- tareas restantes

## Rules

- Nunca implementar tareas no asignadas.
- Specs son criterios de aceptación: no implementar sin leerlas.
- Si el design es incorrecto/incompleto, reportar (no desviarse silenciosamente).
- No correr `sdd-archive` aquí.

