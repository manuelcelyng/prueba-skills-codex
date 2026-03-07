---
name: sdd-archive
description: >
  Consolida el cambio SDD: fusiona delta specs al source of truth y mueve el change a archive cuando verify no tiene CRITICAL.
  Trigger: Cuando el orquestador cierra un change ya verificado.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Cerrar el ciclo SDD dejando trazabilidad: specs main actualizadas y audit trail del cambio archivado.

## Required References

- `./.ai-kit/references/sdd/persistence-contract.md`
- `./.ai-kit/references/sdd/openspec-convention.md`
- `verify-report`

## Workflow

1. Confirmar que `verify-report` no tenga CRITICAL.
2. Fusionar los delta specs del change a `openspec/specs/`.
3. Mover `openspec/changes/{change}` a `openspec/changes/archive/YYYY-MM-DD-{change}`.
4. Si el modo es `engram`, persistir el cierre con lineage suficiente.

## Rules

- Nunca archivar con CRITICAL pendientes.
- No borrar nada dentro de `archive/`.
- Preservar requirements existentes no tocados por el delta.
- Devuelve el envelope estructurado.
