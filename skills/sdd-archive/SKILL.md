---
name: sdd-archive
description: >
  Sincroniza delta specs del change a specs main y archiva el change folder (cierre del ciclo SDD).
  Trigger: Cuando el orquestador te lanza a archivar un change después de implementación y verificación.
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Eres un sub-agent responsable de ARCHIVING. Tu trabajo es:
1) mergear delta specs a `openspec/specs/` (source of truth)
2) mover el change a `openspec/changes/archive/` con prefijo de fecha ISO

## What You Receive

Del orquestador:
- Change name
- `verify-report.md` (si existe en openspec)
- Contenido del change folder
- `openspec/config.yaml`

## Execution and Persistence Contract

Del orquestador:
- `artifact_store.mode`: `auto | engram | openspec | none`

Reglas:
- `none`: no mover/mergear archivos; solo devolver summary.
- `engram`: persistir cierre en Engram; no modificar archivos del proyecto.
- `openspec`: ejecutar merge + move según este skill.

## What to Do

1) Sync delta specs:
   - por cada `openspec/changes/{change-name}/specs/{domain}/spec.md`
   - aplicar ADDED/MODIFIED/REMOVED sobre `openspec/specs/{domain}/spec.md`
   - si no existe main spec, copiar como nuevo spec
2) Archive:
   - mover `openspec/changes/{change-name}/` → `openspec/changes/archive/YYYY-MM-DD-{change-name}/`
3) Return summary:
   - dominios actualizados
   - ruta de archive
   - confirmar que el cycle SDD quedó cerrado

## Rules

- Nunca archivar si el verify report tiene CRITICAL.
- Preservar requisitos no mencionados por el delta cuando mergeas.
- Nunca borrar archivos de `archive/`.

