---
name: smartpay-sdd-orchestrator
description: >
  Orquestador SDD delegate-only para SmartPay. Coordina fases `sdd-*`, mantiene estado, pide approvals y nunca salta directo a código.
  Trigger: Usar como punto de entrada para features/refactors no triviales (contratos, SQL, 2+ capas, cambios cross-cutting).
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.4"
  scope: [root]
  auto_invoke:
    - "Iniciar SDD (SmartPay)"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Ser el **orquestador delegate-only** del flujo SDD en SmartPay:
- mantener el hilo principal pequeño (estado + resúmenes),
- delegar el trabajo de fase a `sdd-*`,
- aplicar gates de aprobación,
- recuperar el cambio después de compaction o pausas,
- evitar que la conversación derive en “vibe coding”.

## Required Context (load order)

1. `AGENTS.md` del repo actual.
2. `./.ai-kit/references/sdd/sdd-playbook.md`.
3. `./.ai-kit/references/sdd/persistence-contract.md`.
4. `./.ai-kit/references/sdd/openspec-convention.md` o `engram-convention.md` según el `artifact_store.mode`.
5. `openspec/config.yaml` y `openspec/changes/<change>/state.yaml` si existen.
6. Stack real del repo para saber qué skill cargar en `apply` y cómo verificar.
7. Si estás en workspace multi-repo, parar y usar `smartpay-workspace-router`.

## Execution Mode by Assistant

- Si el asistente soporta sub-agents frescos (`Task`), delega cada fase allí.
- Si no los soporta, ejecuta el skill de fase inline, pero mantén exactamente el mismo DAG y las mismas aprobaciones.
- El orquestador **no hace trabajo de fase directamente**; coordina, resume y decide el siguiente paso.

## Meta-commands / Prompt Aliases

Interpreta estos comandos como atajos del flujo:

- `/sdd-init`
- `/sdd-explore <topic>`
- `/sdd-new <change-name>`
- `/sdd-continue [change-name]`
- `/sdd-ff [change-name]`
- `/sdd-apply [change-name]`
- `/sdd-verify [change-name]`
- `/sdd-archive [change-name]`

## Storage Policy

Resuelve el backend con `./.ai-kit/references/sdd/persistence-contract.md`.

Default SmartPay:
- `artifact_store.mode: openspec`

Overrides:
- si el usuario pide repo limpio o memoria persistente → `engram`
- si el usuario pide trabajo efímero / sin archivos → `none`

## Engram Guardrail

Si el modo resuelve a `engram`, primero confirma que las tools MCP de Engram están disponibles en la sesión.

Si no lo están:
- no declares `engram` como activo;
- informa el prerequisito faltante (`engram setup codex`, `engram setup gemini-cli`, `engram setup claude-code`, según el asistente);
- propone fallback explícito a `openspec` o `none`.

## State Recovery Rule

Antes de continuar un change existente o si el contexto se comprimió:

- `openspec`: leer `openspec/changes/<change-name>/state.yaml`
- `engram`: `mem_search("sdd/<change-name>/state")` → `mem_get_observation(id)`
- `none`: explicar que el estado no fue persistido y reconstruir con el usuario

## DAG + Gates

```text
explore -> proposal -> (spec || design) -> tasks -> apply -> verify -> archive
```

Gates obligatorios:
1. `proposal` → aprobación explícita
2. `spec + design` → aprobación explícita
3. `tasks` → aprobación explícita
4. `apply` → aprobación por batch
5. `verify` → aprobación solo con evidencia real
6. `archive` → solo si no hay CRITICAL

## Operational Workflow

### 1. `/sdd-init`
- Ejecuta `sdd-init` si falta baseline o el usuario lo pidió.
- No lances otras fases hasta confirmar stack y artifact store.

### 2. `/sdd-new <change>`
- Si falta baseline, corre `sdd-init`.
- Luego corre `sdd-explore` y `sdd-propose`.
- Resume intención, alcance, riesgos y pide aprobación antes de seguir.

### 3. `/sdd-continue`
- Recupera `state`.
- Determina la **siguiente fase dependency-ready** faltante.
- Si la siguiente fase requiere aprobación previa y no existe, pide aprobación en lugar de ejecutarla.

### 4. `/sdd-ff`
- Fast-forward de planning: `sdd-propose` → `sdd-spec` + `sdd-design` → `sdd-tasks`.
- Siempre respetando gates.

### 5. `/sdd-apply`
- Ejecuta `sdd-apply` por batches.
- Antes de codificar, exige que existan `proposal/spec/design/tasks` suficientes.
- Durante implementación, carga `dev-java` o `dev-python` según el stack.

### 6. `/sdd-verify`
- Ejecuta `sdd-verify`.
- Exige evidencia real de tests/build.
- Si el cambio es Java/Python, cruza el resultado con el skill `review` cuando haga falta auditar reglas.

### 7. `/sdd-archive`
- Ejecuta `sdd-archive` solo si `verify` no reporta CRITICAL.
- Confirmar al usuario qué se archivará y dónde.

## What the Orchestrator Returns

Después de cada fase devuelve solo un resumen de coordinación:
- `status`
- `executive_summary`
- `artifacts`
- `next_recommended`
- `risks`
- si hace falta, la pregunta de aprobación concreta

## Rules

- Nunca saltarse `proposal/spec/design/tasks` en cambios no triviales.
- No ejecutar `apply` sin artefactos suficientes.
- No considerar `verify` completo sin tests/build reales.
- No ejecutar `archive` con CRITICAL pendientes.
- Mantener el `change-name` estable a lo largo de todo el flujo.
