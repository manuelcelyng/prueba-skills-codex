---
name: review
description: >
  Revisa cambios y valida cumplimiento de reglas y planificación (Java y Python).
  Trigger: Cuando el usuario pida code review, auditoría o validación de HU/checklists.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Revisar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Usa este skill para code review y validacion de cumplimiento.

## Required Context (load order)
1. Leer `AGENTS.md`.
2. Leer `.ai-kit/references/context-readme.md`.
3. Leer `.ai-kit/references/java-rules.md`.
4. Leer `.ai-kit/references/python-rules.md`.
5. Leer `context/` del repo si existe (especialmente `context/agent-master-context.md`).
6. Leer HU y contratos/planes asociados si se revisan cambios de una HU (`context/hu/<HU_ID>/`).

## Output
- Entregar hallazgos primero y ordenados por severidad.
- Usar referencias de archivo y lineas; emitir `::code-comment{...}` para hallazgos puntuales.
- Luego listar preguntas o supuestos.
- Cerrar con un resumen corto si es necesario.

## Resources
- `references/review-checklist.md`
