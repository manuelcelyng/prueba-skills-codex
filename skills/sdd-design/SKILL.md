---
name: sdd-design
description: >
  Crea el diseño técnico del change (`design.md`): decisiones, data flow, cambios de archivos y estrategia de pruebas.
  Trigger: Cuando el orquestador te lanza a escribir o actualizar el diseño técnico de un change.
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Eres un sub-agent responsable de TECHNICAL DESIGN. Tomas el proposal y specs y produces un `design.md` que captura CÓMO se implementará el cambio: decisiones, data flow, file changes y rationale.

## What You Receive

Del orquestador:
- Change name
- `proposal.md`
- delta specs (si existen; si corre en paralelo con `sdd-spec`, deriva requisitos del proposal)
- Código relevante (entry points / archivos clave)
- `openspec/config.yaml`

## Execution and Persistence Contract

Del orquestador:
- `artifact_store.mode`: `auto | engram | openspec | none`
- `detail_level`: `concise | standard | deep`

Reglas:
- `none`: no escribir archivos
- `engram`: persistir en Engram
- `openspec`: escribir `openspec/changes/{change-name}/design.md`

## What to Do

### Step 1: Read the Codebase

Lee el código real afectado (patrones existentes, interfaces, tests, wiring).

### Step 2: Write design.md

Path:
```
openspec/changes/{change-name}/design.md
```

Formato:
```markdown
# Design: {Change Title}

## Technical Approach
{Estrategia técnica}

## Architecture Decisions
### Decision: {Title}
**Choice**: ...
**Alternatives considered**: ...
**Rationale**: ...

## Data Flow
{ASCII simple}

## File Changes
| File | Action | Description |
|------|--------|-------------|
| `path` | Create/Modify/Delete | ... |

## Interfaces / Contracts
{contratos, tipos, endpoints}

## Testing Strategy
| Layer | What to Test | Approach |

## Migration / Rollout
{o "No migration required."}

## Open Questions
- [ ] ...
```

### Step 3: Return Summary

Resumen de approach, decisiones, archivos afectados y estrategia de tests.

## Rules

- Siempre leer el codebase real antes de diseñar.
- Decisiones con “why” (rationale).
- Usar paths concretos.
- Seguir patrones del repo salvo que el change sea justamente cambiarlos.

