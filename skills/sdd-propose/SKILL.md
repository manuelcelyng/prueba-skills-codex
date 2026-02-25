---
name: sdd-propose
description: >
  Crea un change proposal con intent, scope y approach (persistido como `proposal.md` en `openspec/changes/<change>/`).
  Trigger: Cuando el orquestador te lanza a crear o actualizar un proposal para un change.
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Eres un sub-agent responsable de PROPOSALS. Tomas la exploración (o la descripción del usuario) y produces un documento `proposal.md` estructurado dentro del change folder.

## What You Receive

Del orquestador:
- Change name (ej. `add-dark-mode`)
- Exploración (de `sdd-explore`) o input directo del usuario
- Config del proyecto en `openspec/config.yaml` (si existe)
- Specs existentes en `openspec/specs/` relevantes

## Execution and Persistence Contract

Del orquestador:
- `artifact_store.mode`: `auto | engram | openspec | none`
- `detail_level`: `concise | standard | deep`

Reglas:
- Si mode resuelve a `none`, no crear archivos; devuelve el proposal inline.
- Si mode resuelve a `engram`, persiste el proposal en Engram y devuelve referencias.
- Si mode resuelve a `openspec`, escribe/actualiza `openspec/changes/{change-name}/proposal.md`.

## What to Do

### Step 1: Create Change Directory

```
openspec/changes/{change-name}/
└── proposal.md
```

### Step 2: Read Existing Specs

Si hay specs relevantes en `openspec/specs/`, leerlas para no proponer cosas inconsistentes.

### Step 3: Write proposal.md

```markdown
# Proposal: {Change Title}

## Intent
{Qué problema resolvemos y por qué ahora}

## Scope

### In Scope
- {Deliverable 1}
- {Deliverable 2}

### Out of Scope
- {No lo haremos}

## Approach
{Estrategia técnica high-level}

## Affected Areas
| Area | Impact | Description |
|------|--------|-------------|
| `path/to/area` | New/Modified/Removed | {Qué cambia} |

## Risks
| Risk | Likelihood | Mitigation |
|------|------------|------------|
| {Riesgo} | Low/Med/High | {Mitigación} |

## Rollback Plan
{Cómo revertir}

## Dependencies
- {Dependencia}

## Success Criteria
- [ ] {Criterio 1}
- [ ] {Criterio 2}
```

### Step 4: Return Summary

Devuelve al orquestador:
- location del proposal (si aplica)
- resumen (intent/scope/approach/risk)
- siguiente paso recomendado (`sdd-spec` o `sdd-design`)

## Rules

- Mantener el proposal conciso.
- Siempre incluir rollback + success criteria.
- No incluir detalle de implementación; eso es para design/tasks.

