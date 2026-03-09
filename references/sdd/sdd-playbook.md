# SmartPay SDD Playbook

Guía canónica del flujo Spec-Driven Development del kit. Está inspirada en Agent Teams Lite, pero adaptada a SmartPay y a los asistentes que usa el equipo.

## Principles

- **Delegate-only**: el entrypoint coordina; las fases las hacen `sdd-*`.
- **Artifacts first**: no pasar a código sin `proposal/spec/design/tasks` suficientes.
- **Fresh context when available**: si el asistente soporta sub-agents reales, delega; si no, ejecuta inline manteniendo el mismo DAG.
- **Persistence is explicit**: `openspec` por defecto en SmartPay; `engram` o `none` solo si aplica.
- **Real verification**: `sdd-verify` requiere evidencia de tests/build reales.

## Entry Points

### Un micro
- Skill: `smartpay-sdd-orchestrator`
- Uso típico: `usa smartpay-sdd-orchestrator para el change <change-name>`

### Workspace multi-micro
- Skill: `smartpay-workspace-router`
- Uso típico: `usa smartpay-workspace-router para el change <change-name>`

## Meta-commands / Prompt Aliases

Estos comandos deben interpretarse como atajos del flujo:

- `/sdd-init`
- `/sdd-explore <topic>`
- `/sdd-new <change-name>`
- `/sdd-continue [change-name]`
- `/sdd-ff [change-name]`
- `/sdd-apply [change-name]`
- `/sdd-verify [change-name]`
- `/sdd-archive [change-name]`

## Dependency Graph

```text
explore -> proposal -> (spec || design) -> tasks -> apply -> verify -> archive
```

## Approval Gates

1. `proposal` → aprobación explícita
2. `spec + design` → aprobación explícita
3. `tasks` → aprobación explícita
4. `apply` → aprobación por batch
5. `verify` → aprobar solo con evidencia real
6. `archive` → solo si no hay CRITICAL

## Artifact Store Policy

Ver `persistence-contract.md`.

Resumen SmartPay:
- default: `openspec`
- repo-clean / memoria persistente: `engram`
- efímero: `none`

### Si quieres usar Engram

Asegura primero el setup del asistente con la versión actual de Engram:
- Codex: `engram setup codex`
- Gemini CLI: `engram setup gemini-cli`
- Claude Code: `engram setup claude-code` o plugin marketplace

Si Engram no está disponible en la sesión, no intentes persistir en `engram`; usa `openspec` o `none` explícitamente.

## Assistant Behavior

| Assistant | Execution style |
|-----------|-----------------|
| Claude Code | Delegar con `Task` cuando convenga |
| Codex | Ejecutar fases inline siguiendo skills + gates |
| Gemini CLI | Ejecutar fases inline siguiendo skills + gates |
| Copilot | Ejecutar fases inline siguiendo skills + gates |

## Expected Layout

```text
openspec/
├── config.yaml
├── specs/
└── changes/
    ├── <change-name>/
    │   ├── state.yaml
    │   ├── proposal.md
    │   ├── specs/
    │   ├── design.md
    │   ├── tasks.md
    │   └── verify-report.md
    └── archive/
```

## Phase Deliverables

| Phase | Deliverable | Goal |
|------|-------------|------|
| `sdd-init` | `config.yaml` / contexto | dejar listo el backend de persistencia |
| `sdd-explore` | análisis | entender estado actual y riesgos |
| `sdd-propose` | `proposal.md` | definir intent, scope y success criteria |
| `sdd-spec` | delta specs | definir WHAT con escenarios testables |
| `sdd-design` | `design.md` | definir HOW con decisiones y file changes |
| `sdd-tasks` | `tasks.md` | romper el cambio en tareas pequeñas |
| `sdd-apply` | código + tasks actualizadas | implementar por batches con TDD |
| `sdd-verify` | `verify-report.md` | validar con tests/build reales |
| `sdd-archive` | specs main + archive | cerrar el cambio y dejar audit trail |

## SmartPay-specific Expectations

- Integrar reglas canónicas del stack durante `sdd-apply` (`dev-java` o `dev-python`).
- `sdd-verify` debe contrastar también con `review`.
- Si existe `context/hu/<HU_ID>/`, úsalo como input del proposal/spec/design/tasks; SDD no compite con la HU, la formaliza.
- Para multi-micro, usar el mismo `change-name` y mantener contratos/criterios consistentes entre repos.
