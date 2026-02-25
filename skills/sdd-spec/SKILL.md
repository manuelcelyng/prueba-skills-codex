---
name: sdd-spec
description: >
  Escribe especificaciones (requirements + escenarios) como delta specs para un change en `openspec/changes/<change>/specs/`.
  Trigger: Cuando el orquestador te lanza a escribir o actualizar specs para un change.
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Eres un sub-agent responsable de SPECIFICATIONS. Tomas el proposal y produces delta specs: requisitos y escenarios estructurados que describen lo que se ADICIONA, MODIFICA o REMUEVE del comportamiento del sistema.

## What You Receive

Del orquestador:
- Change name
- Contenido de `proposal.md`
- Specs existentes en `openspec/specs/` (si existen)
- Config del proyecto en `openspec/config.yaml`

## Execution and Persistence Contract

Del orquestador:
- `artifact_store.mode`: `auto | engram | openspec | none`
- `detail_level`: `concise | standard | deep`

Reglas:
- `none`: no escribir archivos
- `engram`: persistir en Engram
- `openspec`: escribir specs en paths definidos

## What to Do

### Step 1: Identify Affected Domains

Desde “Affected Areas”, agrupa por dominio (`auth/`, `payments/`, etc.).

### Step 2: Read Existing Specs

Si existe `openspec/specs/{domain}/spec.md`, léelo para entender el comportamiento actual.

### Step 3: Write Delta Specs

Crear en:

```
openspec/changes/{change-name}/specs/{domain}/spec.md
```

Formato delta:

```markdown
# Delta for {Domain}

## ADDED Requirements

### Requirement: {Name}
The system MUST/SHALL/SHOULD/MAY ...

#### Scenario: {Happy path}
- GIVEN ...
- WHEN ...
- THEN ...

## MODIFIED Requirements
...

## REMOVED Requirements
...
```

Si no existe spec main, crear FULL spec (no delta).

### Step 4: Return Summary

Reportar dominios, conteos (added/modified/removed) y cobertura (happy/edge/error).

## Rules

- Escenarios en Given/When/Then.
- Requisitos con RFC 2119 (MUST/SHALL/SHOULD/MAY).
- Cada requirement debe tener al menos 1 escenario.
- No meter detalles de implementación (WHAT, no HOW).

