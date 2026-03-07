---
name: sdd-spec
description: >
  Escribe especificaciones con requirements y escenarios testables para el change. Usa delta specs cuando ya existe una spec main del dominio.
  Trigger: Cuando el orquestador necesita fijar el WHAT del cambio.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Definir el comportamiento esperado del cambio con requirements y escenarios que luego puedan verificarse automáticamente.

## Required References

- `./.ai-kit/references/sdd/persistence-contract.md`
- `./.ai-kit/references/sdd/openspec-convention.md`
- `openspec/specs/` si existen specs previas

## Workflow

1. Identificar dominios afectados desde el proposal.
2. Leer las specs actuales del dominio si existen.
3. Escribir delta specs (`ADDED`, `MODIFIED`, `REMOVED`) o full spec si el dominio es nuevo.
4. Persistir en `openspec/changes/{change}/specs/{domain}/spec.md` o Engram.

## Rules

- Requisitos con RFC 2119 (`MUST`, `SHALL`, `SHOULD`, `MAY`).
- Escenarios en Given/When/Then.
- Cada requirement debe tener al menos un escenario.
- Incluir happy path, edge cases y error states relevantes.
- No meter detalles de implementación.
- Devuelve el envelope estructurado.
