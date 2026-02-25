---
name: smartpay-workspace-router
description: >
  Router para cambios multi-micro en un workspace con múltiples repos (multi-repo). Descubre repos hermanos y guía el flujo SDD por micro.
  Trigger: Usar cuando el developer tenga 2+ micros clonados y el cambio impacte más de un repo.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Enrutar cambios multi-micro (SmartPay)"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Ayudar a coordinar cambios que impactan múltiples microservicios clonados en el mismo workspace (multi-repo).

Este skill está pensado para usarse **desde el workspace root** (carpeta que contiene múltiples repos con `.git/`).

## Workflow

1) Detectar workspace root (heurística):
   - Listar subcarpetas con `.git/` y construir el inventario de micros disponibles.
2) Listar repos disponibles y pedir confirmación:
   - “¿Qué micros participan?”
3) Asegurar kit listo en esos repos (si aplica):
   - Recomendar ejecutar `./workspace-ai.sh --repos a,b,c --codex|--claude|...` desde el workspace root.
   - Si el workspace no tiene router, recomendar: `./workspace-ai.sh --init-agents --project smartpay --codex`.
4) Ejecutar SDD por micro:
   - Para cada repo seleccionado: iniciar `smartpay-sdd-orchestrator` con el mismo `change-name`.
5) Mantener consistencia:
   - Validar que intent/scope/contratos entre micros no se contradicen.

## Rules

- No intentes escribir un único `openspec/` global del workspace (SmartPay default: uno por micro).
- Si un repo no está clonado localmente, pedir al usuario que lo clone antes de continuar.
