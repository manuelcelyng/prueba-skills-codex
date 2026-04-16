---
name: smartpay-workspace-router
description: >
  Router para cambios multi-micro en un workspace con múltiples repos. Descubre repos hermanos, alinea alcance y coordina el arranque SDD por micro.
  Trigger: Usar cuando el developer tenga 2+ micros clonados y el cambio impacte más de un repo.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.2"
  scope: [root]
  auto_invoke:
    - "Enrutar cambios multi-micro (SmartPay)"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Coordinar cambios que impactan múltiples microservicios dentro del mismo workspace sin crear un `openspec/` global.

## Required Context

1. `AGENTS.md` del workspace root.
2. `references/sdd/sdd-playbook.md`.
3. Inventario real de subrepos con `.git/`.
4. Skills proyectados en el workspace (`.ai/skills/`).

## Workflow

1. Detectar repos disponibles en el workspace.
2. Identificar qué micros participan y cuál es el `change-name` compartido.
3. Confirmar que cada repo tenga AI Kit instalado o explicar cómo instalarlo.
4. Para cada repo participante, arrancar o recomendar arrancar `smartpay-sdd-orchestrator` con el mismo `change-name`.
5. Mantener consistencia entre contratos, success criteria y dependencias cross-micro.
6. Reportar riesgos de coordinación (orden de despliegue, colas, contratos incompatibles, etc.).

## Rules

- Nunca crear un único `openspec/` a nivel workspace.
- Si un micro no está clonado, pedir al usuario que lo clone antes de continuar.
- Si el cambio finalmente toca un solo repo, redirigir al micro y usar `smartpay-sdd-orchestrator`.
- Mantener el mismo `change-name` en todos los micros involucrados salvo instrucción contraria.
