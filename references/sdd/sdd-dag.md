# SmartPay SDD (Agent Teams Lite) — DAG & Gates

Este documento resume el flujo SDD (Spec-Driven Development) como un DAG de fases.

## Fases

1. `sdd-init` (solo si falta `openspec/config.yaml`)
2. `sdd-explore`
3. `sdd-propose` → **Gate: aprobación**
4. `sdd-spec` ∥ `sdd-design` → **Gate: aprobación**
5. `sdd-tasks` → **Gate: aprobación**
6. `sdd-apply` (batches) → **Gate: aprobación por batch**
7. `sdd-verify` (tests/build reales) → **Gate: aprobación**
8. `sdd-archive` (merge specs + archive)

## Reglas de paralelismo (“async”)

- Permitido: `sdd-spec` en paralelo con `sdd-design` (escriben artefactos distintos).
- No permitido: `sdd-apply` en paralelo en el mismo repo/change (riesgo de conflictos).
- `sdd-archive` siempre al final y solo si `verify` quedó OK.

