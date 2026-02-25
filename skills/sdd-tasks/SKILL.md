---
name: sdd-tasks
description: >
  Descompone un change en un checklist de tareas (`tasks.md`) organizado por fases y dependencias.
  Trigger: Cuando el orquestador te lanza a crear o actualizar el breakdown de tareas para un change.
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Eres un sub-agent responsable de TASK BREAKDOWN. Tomas proposal + specs + design y produces `tasks.md` con pasos concretos, verificables y ordenados por dependencia.

## What You Receive

Del orquestador:
- Change name
- `proposal.md`
- delta specs
- `design.md`
- `openspec/config.yaml`

## Execution and Persistence Contract

Del orquestador:
- `artifact_store.mode`: `auto | engram | openspec | none`
- `detail_level`: `concise | standard | deep`

Reglas:
- `none`: no escribir archivos
- `engram`: persistir en Engram
- `openspec`: escribir `openspec/changes/{change-name}/tasks.md`

## What to Do

### Step 1: Analyze the Design

Identifica:
- archivos a crear/modificar/eliminar
- orden de dependencias
- pruebas por escenario/spec

### Step 2: Write tasks.md

Path:
```
openspec/changes/{change-name}/tasks.md
```

Formato:
```markdown
# Tasks: {Change Title}

## Phase 1: Foundation
- [ ] 1.1 {acción concreta con path}

## Phase 2: Core Implementation
- [ ] 2.1 ...

## Phase 3: Integration / Wiring
- [ ] 3.1 ...

## Phase 4: Testing / Verification
- [ ] 4.1 {tests que cubren escenarios}
```

### Step 3: Return Summary

Resumen por fases + orden recomendado.

## Rules

- Tareas específicas, pequeñas y verificables.
- Referenciar paths concretos.
- Orden por dependencias.
- Incluir tareas de testing referenciando escenarios de specs.

