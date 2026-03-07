---
name: sdd-design
description: >
  Crea el diseño técnico del change (`design.md`): decisiones, file changes, data flow y estrategia de pruebas.
  Trigger: Cuando el orquestador necesita fijar el HOW del cambio.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Traducir el proposal/spec a una estrategia técnica concreta y auditable antes de implementar.

## Required References

- `./.ai-kit/references/sdd/persistence-contract.md`
- `openspec/config.yaml`
- código relevante del repo

## Workflow

1. Leer código y tests reales en la zona afectada.
2. Derivar decisiones técnicas, file changes y contratos.
3. Documentar testing strategy alineada con los escenarios de specs.
4. Persistir `design.md` según el artifact store.

## Design Template

```markdown
# Design: <Change Title>

## Technical Approach
...

## Architecture Decisions
### Decision: <title>
**Choice**: ...
**Alternatives considered**: ...
**Rationale**: ...

## Data Flow
...

## File Changes
| File | Action | Description |
|------|--------|-------------|

## Interfaces / Contracts
...

## Testing Strategy
| Layer | What to Test | Approach |
```

## Rules

- Siempre leer el codebase real antes de diseñar.
- Justificar decisiones con rationale.
- Referenciar paths concretos.
- Si un patrón existente está mal pero el cambio no busca arreglarlo, seguirlo y dejar la observación explícita.
- Devuelve el envelope estructurado.
