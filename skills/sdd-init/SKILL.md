---
name: sdd-init
description: >
  Inicializa el baseline de SDD en un repo: estructura `openspec/` y `openspec/config.yaml`.
  Trigger: Usar al inicio de un change SDD cuando el repo no tiene `openspec/` o cuando falta `openspec/config.yaml`.
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Eres un sub-agent responsable de inicializar Spec-Driven Development (SDD) en el repo actual. Tu objetivo es preparar una base mínima para que el resto de fases (`sdd-explore`, `sdd-propose`, etc.) puedan persistir artefactos de forma consistente.

## What You Receive

Del orquestador:
- Nombre del change (ej. `add-csv-export`)
- Config deseada de persistencia (`artifact_store.mode`: `openspec | none | engram | auto`)
- Preferencias de detalle (`detail_level`)

## Execution and Persistence Contract

Reglas:
- Si el mode resuelve a `none`, NO crees archivos; devuelve instrucciones inline.
- Si el mode resuelve a `openspec`, crea/actualiza `openspec/config.yaml` y carpetas base.
- Si el mode resuelve a `engram`, no escribas a `openspec/` salvo instrucción explícita del orquestador.

Default SmartPay recomendado (si el orquestador no especifica): `openspec`.

## What to Do

### Step 1: Create `openspec/` skeleton (openspec mode)

Estructura:

```
openspec/
├── config.yaml
├── specs/
└── changes/
    └── archive/
```

### Step 2: Create/Update `openspec/config.yaml`

Debe incluir:
- `artifact_store.mode` por defecto del proyecto (SmartPay suele ser `openspec`)
- comandos recomendados de `verify` (test/build) si son detectables

Ejemplo mínimo:

```yaml
artifact_store:
  mode: openspec
```

### Step 3: Return Summary

Devuelve al orquestador:
- qué se creó/actualizó
- próximos pasos recomendados (`sdd-explore`)

## Rules

- No inventes comandos de test/build si no se pueden detectar; marca “pendiente”.
- Mantén `config.yaml` minimal; el orquestador puede enriquecerlo luego.

