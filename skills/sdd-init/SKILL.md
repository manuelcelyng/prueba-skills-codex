---
name: sdd-init
description: >
  Inicializa el contexto Spec-Driven Development del repo: detecta stack, configura el artifact store y deja listo `openspec/` o Engram según corresponda.
  Trigger: Usar al inicio de un change SDD cuando el repo no tiene baseline o cuando el usuario pide inicializar/rehidratar el flujo.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Preparar el baseline SDD del proyecto sin inventar contexto. Detecta stack, comandos reales y backend de persistencia.

## Required References

- `./.ai-kit/references/sdd/persistence-contract.md`
- `./.ai-kit/references/sdd/openspec-convention.md`
- `./.ai-kit/references/sdd/engram-convention.md` (solo si el modo resuelve a `engram`)
- `AGENTS.md` del repo

## What You Receive

- `change-name` opcional
- `artifact_store.mode`
- `detail_level`

## Workflow

### 1. Detect project context

Lee el repo para identificar:
- stack real (`gradlew`, `build.gradle*`, `pyproject.toml`, `requirements*`, etc.)
- arquitectura dominante
- comandos de test/build detectables
- convenciones relevantes del repo

### 2. Initialize persistence backend

- `openspec`: crea `openspec/`, `openspec/specs/`, `openspec/changes/`, `openspec/changes/archive/` y `openspec/config.yaml`.
- `engram`: persiste el contexto del proyecto con la convención `sdd-init/{project-name}`; no crees `openspec/`.
- `none`: no escribas archivos; devuelve el contexto detectado inline.

### 3. Generate concise config (openspec)

`openspec/config.yaml` debe ser breve y accionable. Incluye solo lo que detectes con confianza:

```yaml
schema: smartpay-sdd
artifact_store:
  mode: openspec
context: |
  Stack: <detectado>
  Architecture: <detectada>
  Tests: <detectados>
rules:
  apply:
    tdd: true
    test_command: <si es detectable>
  verify:
    test_command: <si es detectable>
    build_command: <si es detectable>
```

## Rules

- No inventes comandos de test/build si no son detectables; déjalos pendientes.
- No crees spec placeholders vacíos.
- Mantén el `context` corto (máximo 8–10 líneas).
- Devuelve el envelope estructurado (`status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`).
