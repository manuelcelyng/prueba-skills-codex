# AI Kit — Install & Usage (SmartPay)

Este repo contiene el **AI Kit** (skills + tools + references) para integrarlo en repos de servicios y workspaces multi-repo.

## Qué cambió en este kit

Además de las reglas canónicas por stack, el kit ahora proyecta un flujo **Spec-Driven Development** inspirado en Agent Teams Lite:

- orquestador **delegate-only** por micro (`smartpay-sdd-orchestrator`)
- router multi-micro (`smartpay-workspace-router`)
- fases `sdd-*` con DAG y gates
- backend de artefactos pluggable (`openspec | engram | none`)
- overlays SDD por asistente al ejecutar `setup.sh`

La fuente de verdad del flujo está en:
- `references/sdd/sdd-playbook.md`
- `references/sdd/persistence-contract.md`
- `references/sdd/openspec-convention.md`
- `references/sdd/engram-convention.md`

## Project profile (`--project`)

Por defecto el kit asume `--project smartpay`.

SmartPay incluye:
- `smartpay-sdd-orchestrator`
- `sdd-*`
- `smartpay-workspace-router` (solo en workspace root)
- reglas canónicas de implementación/review para Java y Python

## Quick start (1 repo / 1 microservicio)

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/install.sh | bash
```

Durante la instalación podrás elegir asistentes. Si presionas Enter sin seleccionar nada, se configura **Codex**.

## Qué instala

En cada repo del micro:
- `ai-kit.lock`
- `scripts/ai/*`
- `.ai-kit/`
- `.ai/skills/`
- `AGENTS.md` stub si no existía
- `.codex/skills`, `.claude/skills`, `.gemini/skills` según el setup
- `CLAUDE.md`, `GEMINI.md` y `.github/copilot-instructions.md` con overlays SDD cuando aplica

## SDD Quick Start

### Un micro

Usa el entrypoint:
- `smartpay-sdd-orchestrator`

Aliases soportados por el flujo:
- `/sdd-init`
- `/sdd-new <change-name>`
- `/sdd-continue`
- `/sdd-ff <change-name>`
- `/sdd-apply`
- `/sdd-verify`
- `/sdd-archive`

### Workspace multi-repo

1. Inicializa el workspace root:
```bash
./workspace-ai.sh --init-agents --project smartpay --codex
```
2. Usa `smartpay-workspace-router`.
3. Ejecuta el mismo `change-name` en cada micro involucrado.

## Artifact store policy

SmartPay usa por defecto:
- `openspec`

También soporta:
- `engram` → persistencia sin archivos del repo
- `none` → flujo efímero

## Assistant behavior

| Assistant | Cómo opera el flujo |
|-----------|---------------------|
| Codex | Inline, siguiendo skills + gates |
| Claude Code | Puede delegar con `Task` cuando convenga |
| Gemini CLI | Inline, siguiendo skills + gates |
| Copilot | Inline, siguiendo skills + gates |

## Filosofía `AGENTS.md` stub-first

Si el repo no tiene `AGENTS.md`, el kit crea un stub mínimo y la primera acción debe ser `ai-init-agents`.

Ese skill debe dejar un `AGENTS.md` final con:
- tablas de skills realmente proyectadas,
- comandos build/test reales,
- reglas no negociables del repo,
- quick start SDD,
- referencia a `dev-java` / `dev-python` y `review` como rulebooks.

## Scripts clave

- `install.sh` → instala el kit en un repo
- `workspace-install.sh` → instala el kit en varios repos
- `tools/setup.sh` → proyecta skills y genera/copía overlays por asistente
- `tools/sync.sh` → regenera `### Auto-invoke Skills`
- `tools/init-agents.sh` → crea stub inicial
- `tools/init-workspace-agents.sh` → crea router del workspace
- `tools/build-skills.sh` → arma `.ai/skills`
