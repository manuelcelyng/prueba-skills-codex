---
name: review
description: >
  Revisa cambios y valida cumplimiento de reglas y planificación (Java y Python).
  Trigger: Cuando el usuario pida code review, auditoría o validación de HU/checklists.
license: Internal
metadata:
  author: pragma-smartpay
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
3. Leer `.ai-kit/references/java-rules.md` (si aplica Java).
4. Leer `.ai-kit/references/python-rules.md` (si aplica Python).
5. Leer `.ai-kit/references/review-checklist.md`.
6. Si hay HU, leer `context/hu/<HU_ID>/` (contrato/plan).
7. Si existe skill local relevante (ej. `skills/*/SKILL.md`), cargar solo el necesario.

## Output
- Entregar hallazgos primero y ordenados por severidad.
- Usar referencias de archivo y lineas; emitir `::code-comment{...}` para hallazgos puntuales.
- Luego listar preguntas o supuestos.
- Cerrar con un resumen corto si es necesario.

## Checks (mínimo)
- Aplicar reglas por ID (fuente de verdad): `.ai-kit/references/java-rules.md`
  - Arquitectura/capas: `R-JAVA-001`
  - Reactividad/streaming/batch: `R-JAVA-002`..`R-JAVA-005`
  - Persistencia/SQL: `R-JAVA-006`..`R-JAVA-007`, `R-JAVA-018`
  - Errores/logging/constantes: `R-JAVA-008`..`R-JAVA-010`
  - Contrato API: `R-JAVA-011`
  - Naming UseCases: `R-JAVA-012`
  - Tests/TestData: `R-JAVA-013`..`R-JAVA-015`
  - Clean code: `R-JAVA-016`
  - E2E LocalStack: `R-JAVA-017`

## Resources
- `.ai-kit/references/java-rules.md`
- `.ai-kit/references/review-checklist.md`
