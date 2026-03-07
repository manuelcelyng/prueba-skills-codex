---
name: sdd-propose
description: >
  Crea el change proposal con intent, scope, rollback y success criteria. Persistencia: `proposal.md` o Engram según el artifact store.
  Trigger: Cuando el orquestador necesita formalizar el cambio antes de pasar a specs/design.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Formalizar el cambio en un `proposal` corto y aprobable por el usuario antes de diseñar o implementar.

## Required References

- `./.ai-kit/references/sdd/persistence-contract.md`
- `./.ai-kit/references/sdd/openspec-convention.md`
- specs actuales de `openspec/specs/` si existen

## Workflow

1. Tomar el output de exploración o el request del usuario.
2. Leer specs existentes para evitar contradicciones.
3. Crear `proposal.md` con intención, alcance, rollback y success criteria.
4. Persistir según el artifact store.

## Proposal Template

```markdown
# Proposal: <Change Title>

## Intent
...

## Scope
### In Scope
- ...
### Out of Scope
- ...

## Approach
...

## Affected Areas
| Area | Impact | Description |
|------|--------|-------------|

## Risks
| Risk | Likelihood | Mitigation |
|------|------------|------------|

## Rollback Plan
...

## Dependencies
- ...

## Success Criteria
- [ ] ...
```

## Rules

- Siempre incluir `Rollback Plan` y `Success Criteria`.
- No incluir detalle fino de implementación; eso va a `design.md` y `tasks.md`.
- Mantenerlo corto y orientado a aprobación.
- Devuelve el envelope estructurado.
