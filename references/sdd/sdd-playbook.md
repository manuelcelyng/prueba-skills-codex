# SmartPay SDD Playbook

Guía mínima y canónica para arrancar y operar el flujo Spec-Driven Development (SDD) en el kit.

## Source of truth

1. `AGENTS.md` del repo o del workspace.
2. Skill activo (`smartpay-sdd-orchestrator`, `smartpay-workspace-router`, `dev-*`, `review`).
3. Artefactos `openspec/` y/o `context/hu/<HU_ID>/`.

## Cuándo usar SDD

Usa SDD cuando el cambio tenga cualquiera de estos rasgos:
- toca 2 o más capas;
- introduce/ajusta contrato, SQL o reglas de negocio;
- impacta varios archivos/módulos;
- afecta más de un microservicio;
- requiere coordinación entre implementación y verificación.

## Quick start

### Un solo micro

1. Abre el repo del micro.
2. Asegura AI Kit instalado y skills proyectados.
3. Inicia el cambio con `smartpay-sdd-orchestrator`.
4. Usa un `change-name` corto en kebab-case.

### Workspace multi-repo

1. Desde el workspace root ejecuta `./workspace-ai.sh --init-agents --project smartpay --codex`.
2. Abre la sesión en el workspace root.
3. Inicia con `smartpay-workspace-router`.
4. Ejecuta el mismo `change-name` en cada micro involucrado.

## Layout esperado en `openspec/`

```text
openspec/
├── config.yaml
├── specs/
└── changes/
    ├── <change-name>/
    │   ├── proposal.md
    │   ├── design.md
    │   ├── tasks.md
    │   ├── specs/
    │   │   └── <domain>/spec.md
    │   └── verify-report.md   # opcional, si verify escribe al repo
    └── archive/
```

## DAG y gates

1. `sdd-init` → crea baseline si falta `openspec/config.yaml`.
2. `sdd-explore` → investiga el estado actual.
3. `sdd-propose` → define intención/alcance. **Gate de aprobación**.
4. `sdd-spec` + `sdd-design` → definen WHAT y HOW. **Gate de aprobación**.
5. `sdd-tasks` → descompone en checklist. **Gate de aprobación**.
6. `sdd-apply` → implementa por batches. **Gate por batch**.
7. `sdd-verify` → exige evidencia real (tests/build). **Gate de aprobación**.
8. `sdd-archive` → consolida y archiva cuando no hay CRITICAL.

## Regla dura

No pasar a `sdd-apply` si no existen specs/design/tasks suficientes.

## Relación con HUs tradicionales

Si tu equipo ya trabaja con `context/hu/<HU_ID>/`:
- el **contrato** de la HU alimenta `proposal/spec`;
- el **plan de implementación** alimenta `design/tasks`;
- las pruebas y hallazgos de la HU alimentan `verify`.

SDD no reemplaza necesariamente la HU; puede usarla como insumo y dejar el cambio persistido en `openspec/`.

## Qué debe quedar listo antes de implementar

- alcance y out-of-scope explícitos;
- contrato/interfaz clara;
- reglas de negocio y errores relevantes definidos;
- plan técnico por capas;
- checklist de tareas verificables.

## Qué debe quedar listo antes de cerrar

- evidencia real de tests/build;
- cambios alineados con contrato/specs;
- tareas actualizadas;
- artifacts archivables sin CRITICAL pendientes.
