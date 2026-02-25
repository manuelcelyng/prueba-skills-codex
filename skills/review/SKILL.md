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
- Naming queries:
  - Si el query es simple, preferir derived query en `ReactiveCrudRepository`/`CrudRepository` (por nombre).
  - Si el query es complejo, permitir `DatabaseClient`/SQL Providers; si es intermedio y legible, `@Query`.
- Naming de UseCases:
  - Evitar métodos llamados `execute` en UseCases; el nombre debe describir claramente la funcionalidad.
- Reactor:
  - Evitar `collectList()` + `Flux::fromIterable` solo para reemitir; preferir streaming (`concatMap` si secuencial/ordenado).
- Batch:
  - En flujos por lote, manejar errores por elemento (`onErrorResume` por item/lote) para que un fallo no aborte el proceso completo.
- Tests:
  - Evitar data hardcodeada de negocio (ej. estados como `NUEVO`) directamente en los tests.
  - Centralizar constantes/objetos/fixtures en clases `*TestData` del módulo (siguiendo la estructura existente).
  - `*TestData` como utility consistente (ej. `@UtilityClass` si el repo usa Lombok) y nombres descriptivos (evitar `b1`, `b2`).
- E2E (LocalStack):
  - Verificar que el cliente SQS apunte al endpoint correcto; aislar cambios “solo local” para no contaminar prod.

## Resources
- `.ai-kit/references/review-checklist.md`
