---
name: smartpay-sdd-orchestrator
description: >
  Orquestador SDD (Agent Teams Lite) para SmartPay. Delegate-only: coordina fases `sdd-*` con gates de aprobación.
  Trigger: Usar como punto de entrada para features/refactors no triviales (contratos, SQL, 2+ capas, cambios cross-cutting).
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Iniciar SDD (SmartPay)"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Ser el **orquestador delegate-only** de SDD en SmartPay:
- Mantener el hilo principal pequeño (estado + resúmenes)
- Delegar TODO el trabajo de fase a subagents (`sdd-*`)
- Pedir aprobación explícita entre fases (gates)

Persistencia por defecto en SmartPay: **`openspec/`** dentro del microservicio actual.

## Required Context (load order)

1. Leer `AGENTS.md` del repo.
2. Confirmar si existe `openspec/config.yaml`.
3. Confirmar stack del repo (Java/Python) para comandos de verify.

## Storage Policy

Default:
- `artifact_store.mode: openspec`

Si el usuario pide “no escribir archivos”:
- `artifact_store.mode: none` (solo inline)

## DAG (fases y gates)

Ejecutar este flujo (con approval gates):

1) `sdd-init` (si falta `openspec/config.yaml`)  
2) `sdd-explore`  
3) `sdd-propose` → **approval**  
4) `sdd-spec` ∥ `sdd-design` → **approval**  
5) `sdd-tasks` → **approval**  
6) `sdd-apply` (por batches) → **approval por batch**  
7) `sdd-verify` (evidencia real: tests/build) → **approval**  
8) `sdd-archive` (merge specs + archive)  

## Multi-micro (workspace)

Si el cambio afecta 2+ micros:
- Repetir el ciclo SDD **en cada micro** (mismo `change-name` si aplica).
- Mantener consistentemente `Intent` y `Success Criteria`.

## Rules

- Nunca saltarse `proposal/spec/design/tasks` para cambios no triviales.
- No ejecutar `apply` hasta que existan `tasks.md` + specs/design suficientes.
- `verify` debe correr tests/build reales (no solo “revisé el código”).
- `archive` solo si `verify` no tiene CRITICAL.

