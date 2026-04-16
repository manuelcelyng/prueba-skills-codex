---
name: sdd-tasks
description: >
  Descompone el change en tareas pequeñas, numeradas y ordenadas por dependencia. Persiste `tasks.md`.
  Trigger: Cuando el orquestador necesita el checklist listo para implementación por batches.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Romper el cambio en un checklist ejecutable por sesiones cortas, alineado con specs y design.

## Required References

- `references/sdd/persistence-contract.md`
- `design.md`, specs y proposal
- `openspec/config.yaml`

## Workflow

1. Identificar archivos a tocar, dependencias y orden.
2. Crear fases con numeración jerárquica (`1.1`, `1.2`, `2.1`, ...).
3. Incluir tareas de pruebas alineadas con escenarios.
4. Si `rules.apply.tdd=true`, descomponer tareas en RED / GREEN / REFACTOR cuando aporte claridad.

## Rules

- Cada tarea debe ser específica, accionable y verificable.
- Referenciar paths concretos.
- Ordenar por dependencia real.
- No usar tareas vagas como “implementar feature”.
- Devuelve el envelope estructurado.
