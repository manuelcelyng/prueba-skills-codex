# AI Kit — Install & Usage (SmartPay)

Este repo contiene el **AI Kit** (skills + tools + references) para integrarlo en repos de servicios y workspaces multi-repo.

## Modelo de instalación

El instalador copia skills, references y steering files **directamente** a las carpetas nativas de cada agente (`.kiro/`, `.codex/`, `.claude/`, `.gemini/`). No se crea `.ai-kit/`, `.ai/`, `ai-kit.lock` ni `scripts/ai/` en el repo destino.

### Agentes soportados

| Agente | Skills | References | Instrucciones | Steering |
|--------|--------|------------|---------------|----------|
| Kiro | `.kiro/skills/` | `.kiro/references/` | — (usa steering) | `.kiro/steering/*.md` |
| Codex | `.codex/skills/` | `.codex/references/` | `AGENTS.md` | — |
| Claude | `.claude/skills/` | `.claude/references/` | `CLAUDE.md` | — |
| Gemini | `.gemini/skills/` | `.gemini/references/` | `GEMINI.md` | — |
| Copilot | — | — | `.github/copilot-instructions.md` | — |

> Las references son transversales: todo agente que recibe skills también recibe references, porque las skills las referencian directamente.

## Quick start (1 repo / 1 microservicio)

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/install.sh | bash
```

Durante la instalación podés elegir agentes. Si presionás Enter sin seleccionar nada, se configura **Kiro** (default).

### Con flags explícitos

```bash
bash install.sh --kiro --codex
bash install.sh --all --force
bash install.sh --kit-ref v2.0 --codex --claude
```

## Quick start (workspace multi-repo)

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/workspace-install.sh | bash
```

O con flags:

```bash
bash workspace-install.sh --kiro --codex --repos dispersion,pagos
bash workspace-install.sh --all --force
```

El workspace installer:
1. Copia skills/references/steering al workspace root
2. Crea symlinks relativos en cada micro apuntando al workspace root
3. Genera `workspace-ai.sh` runner

### Estructura resultante (workspace)

```
workspace/
├── .kiro/
│   ├── skills/          # Copia directa
│   ├── references/      # Copia directa
│   └── steering/        # Generado con frontmatter Kiro
├── .codex/
│   ├── skills/          # Copia directa
│   └── references/      # Copia directa
├── micro-a/
│   ├── .kiro/
│   │   ├── skills → ../../.kiro/skills        # Symlink relativo
│   │   ├── references → ../../.kiro/references
│   │   └── steering → ../../.kiro/steering
│   └── .codex/
│       ├── skills → ../../.codex/skills
│       └── references → ../../.codex/references
├── AGENTS.md
└── workspace-ai.sh
```

## Opciones del instalador

### install.sh

| Flag | Descripción |
|------|-------------|
| `--kit-repo <url>` | URL del repo ai-kit (default: GitHub) |
| `--kit-ref <ref>` | Branch/tag/commit (default: main) |
| `--project <name>` | Perfil de filtrado de skills (default: smartpay) |
| `--kiro` | Configurar Kiro |
| `--codex` | Configurar Codex |
| `--claude` | Configurar Claude |
| `--gemini` | Configurar Gemini |
| `--copilot` | Configurar Copilot |
| `--all` | Configurar todos los agentes |
| `--force` | Sobrescribir archivos existentes |
| `--no-setup` | Solo descargar, no configurar |

### workspace-install.sh

Mismos flags que install.sh, más:

| Flag | Descripción |
|------|-------------|
| `--repos <a,b,c>` | Solo configurar estos micros |
| `--no-runner` | No crear workspace-ai.sh |
| `--setup-interactive` | Preguntar una vez, aplicar a todos |
| `--setup-none` | No configurar agentes |

## Project profile (`--project`)

Por defecto el kit asume `--project smartpay`.

SmartPay incluye:
- `smartpay-sdd-orchestrator`
- `sdd-*`
- `smartpay-workspace-router` (solo en workspace root)
- Reglas canónicas de implementación/review para Java y Python

## SDD Quick Start

Usa el entrypoint `smartpay-sdd-orchestrator`:

- `/sdd-init` — inicializar contexto SDD
- `/sdd-new <change>` — nuevo cambio
- `/sdd-continue` — continuar fase siguiente
- `/sdd-ff <change>` — fast-forward planning
- `/sdd-apply` — implementar
- `/sdd-verify` — verificar
- `/sdd-archive` — archivar

Playbook completo: `references/sdd/sdd-playbook.md`

## Scripts

| Script | Descripción |
|--------|-------------|
| `install.sh` | Instala el kit en un repo (copia directa) |
| `workspace-install.sh` | Instala el kit en un workspace multi-repo |
| `tools/lib.sh` | Funciones compartidas (detect_stack, should_include_skill) |
| `tools/sync.sh` | Regenera `### Auto-invoke Skills` en AGENTS.md |
| `tools/init-agents.sh` | Crea AGENTS.md stub para un repo |
| `tools/init-workspace-agents.sh` | Crea AGENTS.md router para workspace |

## Verificación post-instalación

El instalador verifica automáticamente que:
- Cada agente tiene `skills/` con al menos un skill
- Cada agente con skills tiene `references/` con archivos
- Kiro tiene `steering/` con al menos un archivo `.md`

Si la verificación falla, reporta el path problemático y retorna exit code ≠ 0.

## Idempotencia

Re-ejecutar el instalador actualiza skills y references sin romper nada. Los archivos de instrucciones (AGENTS.md, CLAUDE.md, etc.) y steering files se preservan salvo que se use `--force`.

## Detección de artefactos legacy

Si el instalador detecta `.ai-kit/`, `.ai/`, `scripts/ai/` o `ai-kit.lock`, emite un warning sugiriendo eliminarlos manualmente.
