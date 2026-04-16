---
name: sdd-verify
description: >
  Verifica que la implementación cumple specs, design y tasks con evidencia de ejecución real (tests/build). Es el quality gate antes de archive.
  Trigger: Cuando el orquestador necesita validar un change completado o un batch relevante.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Ser la compuerta de calidad del cambio: comprobar completitud, coherencia y cumplimiento comportamental con evidencia real.

## Required References

- `references/sdd/persistence-contract.md`
- `proposal`, `spec`, `design`, `tasks`
- `openspec/config.yaml`
- `./.ai/skills/review/SKILL.md`

## Workflow

1. Validar completitud de `tasks.md`.
2. Cruzar cada requirement/scenario con evidencia estructural en código.
3. Validar que el diseño realmente se siguió.
4. Ejecutar tests reales y, si aplica, build real.
5. Construir una matriz requirement/scenario → test → resultado.
6. Persistir el `verify-report` según el artifact store.

## Verdict Levels

- **CRITICAL**: bloquea archive
- **WARNING**: debería corregirse, pero no siempre bloquea
- **SUGGESTION**: mejora opcional

## Rules

- Análisis estático solo no alcanza; debes ejecutar tests.
- Un escenario es COMPLIANT solo si existe una prueba que cubra ese escenario y pasó.
- No arregles findings aquí; solo reporta.
- Si un comando de test/build falla, es CRITICAL salvo que el usuario haya acotado el alcance de otra forma.
- Devuelve el envelope estructurado.
