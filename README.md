# AI Kit (ASULADO) — Install & Usage

Este repo contiene el **AI Kit** (skills + tools + references) para integrarlo en repos de servicios (microservicios) y/o en workspaces con múltiples repos.

## Quick start (1 repo / 1 microservicio)

Desde el root del repo del micro (donde existe `.git`):

### Instalación interactiva (recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/install.sh | bash
```

Durante la instalación podrás elegir qué asistentes configurar (Claude/Gemini/Codex/Copilot).
Por defecto verás todo deseleccionado; si presionas Enter sin seleccionar nada, se configura **Codex**.

### Instalación no interactiva (sin preguntas)

Configurar todos los asistentes:

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/install.sh | bash -s -- --all
```

Configurar un subconjunto:

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/install.sh | bash -s -- --claude --codex
```

### Solo instalar archivos (no ejecutar bootstrap/setup/sync)

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/install.sh | bash -s -- --no-run
```

### Saltar `setup` (no crea symlinks/copias; sí hace sync)

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/install.sh | bash -s -- --no-setup
```

### Sobrescribir archivos existentes

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/install.sh | bash -s -- --force
```

## Workspace (múltiples repos)

Desde el root de una carpeta que contenga múltiples repos (subcarpetas con `.git`):

### Instalar en todos (default: setup all)

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/workspace-install.sh | bash
```

### Elegir asistentes una vez y aplicar a todos

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/workspace-install.sh | bash -s -- --setup-interactive
```

### Saltar setup en todos

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/workspace-install.sh | bash -s -- --setup-none
```

### Instalar solo en repos específicos

```bash
curl -fsSL https://raw.githubusercontent.com/manuelcelyng/prueba-skills-codex/main/workspace-install.sh | bash -s -- --repos dispersion,pagos,recepcion
```

## Qué instala / qué genera

En cada repo de microservicio:
- `ai-kit.lock` (apunta a este repo y un ref)
- `scripts/ai/`:
  - `bootstrap.sh` (clona `.ai-kit/` en el repo)
  - `init-agents.sh` (crea `AGENTS.md` si falta)
  - `setup.sh` (genera `.ai/skills` y configura `.claude/.gemini/.codex/.github`)
  - `sync.sh` (regenera `### Auto-invoke Skills` en `AGENTS.md`)
  - `create-skill.sh` (scaffold de skills locales en `skills/`)
- `.gitignore` (bloque “AI KIT” para ignorar `.ai-kit/`, `.ai/`, symlinks y archivos generados)

### Directorios clave en el repo del micro

- `.ai-kit/`: clone del AI Kit (vendor).
- `.ai/skills/`: **proyección efectiva** (merge de `.ai-kit/skills/*` + `./skills/*`).
- `.claude/skills`, `.gemini/skills`, `.codex/skills`: symlinks a `.ai/skills`.

## Actualizar skills / auto-invoke

En el repo del micro:

```bash
./scripts/ai/bootstrap.sh
./scripts/ai/setup.sh --all
./scripts/ai/sync.sh
```

## Crear un skill específico del micro

Ejemplo:

```bash
./scripts/ai/create-skill.sh --name <micro>-<tema> --auto "<Action>"
./scripts/ai/setup.sh --all
./scripts/ai/sync.sh
```
