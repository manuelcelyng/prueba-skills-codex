# SmartPay OpenSpec Convention

Layout canónico para persistir cambios SDD en archivos del repo.

## Directory Structure

```text
openspec/
├── config.yaml
├── specs/
│   └── {domain}/
│       └── spec.md
└── changes/
    ├── archive/
    └── {change-name}/
        ├── state.yaml
        ├── exploration.md      # opcional
        ├── proposal.md
        ├── specs/
        │   └── {domain}/spec.md
        ├── design.md
        ├── tasks.md
        └── verify-report.md
```

## Artifact Paths

| Skill | Path |
|-------|------|
| `smartpay-sdd-orchestrator` | `openspec/changes/{change-name}/state.yaml` |
| `sdd-init` | `openspec/config.yaml`, `openspec/specs/`, `openspec/changes/`, `openspec/changes/archive/` |
| `sdd-explore` | `openspec/changes/{change-name}/exploration.md` (opcional) |
| `sdd-propose` | `openspec/changes/{change-name}/proposal.md` |
| `sdd-spec` | `openspec/changes/{change-name}/specs/{domain}/spec.md` |
| `sdd-design` | `openspec/changes/{change-name}/design.md` |
| `sdd-tasks` | `openspec/changes/{change-name}/tasks.md` |
| `sdd-apply` | actualiza `openspec/changes/{change-name}/tasks.md` |
| `sdd-verify` | `openspec/changes/{change-name}/verify-report.md` |
| `sdd-archive` | mueve el change a `openspec/changes/archive/YYYY-MM-DD-{change-name}/` y fusiona deltas a `openspec/specs/` |

## config.yaml Baseline

`openspec/config.yaml` debe mantener contexto corto y reglas accionables:

```yaml
schema: smartpay-sdd
artifact_store:
  mode: openspec
context: |
  Stack: Java 21 + Spring Boot WebFlux
  Architecture: hexagonal / clean
  Tests: JUnit 5 + Mockito + StepVerifier
rules:
  proposal:
    - incluir rollback plan y áreas afectadas
  specs:
    - usar Given/When/Then
    - usar RFC 2119
  design:
    - listar file changes y rationale
  tasks:
    - fases numeradas y tareas pequeñas
  apply:
    tdd: true
    test_command: ./gradlew test
  verify:
    test_command: ./gradlew test
    build_command: ./gradlew build
```
```

## Reading Rules

Antes de escribir un artefacto:
- crea el change folder si no existe;
- lee la versión actual del archivo si ya existe;
- si hay specs main, úsalas como “current behavior”; los cambios van como delta.

## Archive Rules

- Nunca borres `archive/`.
- No archives si `verify-report` tiene CRITICAL.
- Usa fecha ISO del día en el nombre del directorio archivado.
