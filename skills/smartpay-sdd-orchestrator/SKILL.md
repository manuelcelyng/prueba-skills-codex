---
name: smartpay-sdd-orchestrator
description: >
  Orquestador SDD (Agent Teams Lite) para SmartPay. Delegate-only: coordina fases `sdd-*` con gates de aprobación.
  Trigger: Usar como punto de entrada para features/refactors no triviales (contratos, SQL, 2+ capas, cambios cross-cutting).
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.2"
  scope: [root]
  auto_invoke:
    - "Iniciar SDD (SmartPay)"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Ser el **orquestador delegate-only** de SDD en SmartPay:
- mantener el hilo principal pequeño (estado + resúmenes),
- delegar TODO el trabajo de fase a subagents (`sdd-*`),
- pedir aprobación explícita entre fases (gates),
- asegurar que no se salte de idea a código sin specs/tasks.

Persistencia por defecto en SmartPay: **`openspec/`** dentro del microservicio actual.

## Required Context (load order)

1. Leer `AGENTS.md` del repo.
2. Confirmar si existe `openspec/config.yaml`.
3. Confirmar stack del repo (Java/Python) para comandos de verify.
4. Si el usuario está en un workspace multi-repo, preferir `smartpay-workspace-router` antes de arrancar el change.
5. Si necesitas ayuda de layout/gates, usar `.ai-kit/references/sdd/sdd-playbook.md`.

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
- arrancar desde el workspace root con `smartpay-workspace-router`;
- repetir el ciclo SDD **en cada micro** (mismo `change-name` si aplica);
- mantener consistencia de `Intent`, `Success Criteria` y contratos entre micros.

## Rules

- Nunca saltarse `proposal/spec/design/tasks` para cambios no triviales.
- No ejecutar `apply` hasta que existan `tasks.md` + specs/design suficientes.
- `verify` debe correr tests/build reales (no solo análisis estático).
- `archive` solo si `verify` no tiene CRITICAL.
