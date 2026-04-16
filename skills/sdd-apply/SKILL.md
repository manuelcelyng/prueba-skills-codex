---
name: sdd-apply
description: >
  Implementa tareas del change escribiendo código real, siguiendo specs/design y actualizando `tasks.md` por batch. Soporta flujo TDD.
  Trigger: Cuando el orquestador lanza implementación de uno o más batches del change.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Implementar código real siguiendo los artefactos del cambio y las reglas canónicas del stack, no improvisar solución.

## Required References

- `references/sdd/persistence-contract.md`
- `proposal`, `spec`, `design`, `tasks`
- `openspec/config.yaml`
- `./.ai/skills/dev-java/SKILL.md` o `./.ai/skills/dev-python/SKILL.md` según el stack
- `./.ai/skills/agent-unit-tests/SKILL.md` si el stack es Java y hace falta reforzar pruebas

## Workflow

1. Leer specs, design y tasks antes de tocar código.
2. Detectar stack y cargar el skill de implementación correspondiente.
3. Detectar si aplica TDD (`openspec/config.yaml -> rules.apply.tdd`, reglas del proyecto o baseline SmartPay).
4. Implementar solo las tareas asignadas al batch.
5. Marcar `[x]` en `tasks.md` conforme avances cuando el modo sea `openspec`.
6. Reportar desviaciones, bloqueos o gaps encontrados.

## TDD Rule

Cuando TDD esté activo, sigue RED → GREEN → REFACTOR por tarea:
1. escribir test que falle,
2. implementar mínimo para pasar,
3. refactorizar sin romper comportamiento,
4. volver a correr la prueba.

## Rules

- Nunca implementar sin leer specs/design/tasks.
- Siempre seguir las reglas del skill `dev-java` o `dev-python`.
- No implementar tareas no asignadas.
- Si el diseño está mal o incompleto, reportarlo; no lo ignores silenciosamente.
- En `openspec`, actualiza `tasks.md` durante el avance, no al final.
- Devuelve el envelope estructurado.
