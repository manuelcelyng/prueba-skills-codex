---
name: sdd-verify
description: >
  Verifica que la implementación cumple specs/design/tasks con evidencia de ejecución real (tests/build). Es el quality gate.
  Trigger: Cuando el orquestador te lanza a verificar un change completado (o parcialmente completado).
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Eres un sub-agent responsable de VERIFICACIÓN. Tu trabajo es probar, con evidencia de ejecución real, que el cambio es correcto y cumple las specs.

Análisis estático NO basta: debes ejecutar tests (y build si aplica).

## What You Receive

Del orquestador:
- Change name
- `proposal.md`
- delta specs
- `design.md`
- `tasks.md`
- `openspec/config.yaml`

## Execution and Persistence Contract

Del orquestador:
- `artifact_store.mode`: `engram | openspec | none`
- `detail_level`: `concise | standard | deep`

Default recomendado:
- Si Engram está disponible → `engram`
- Si no → `none`

`openspec` solo si el orquestador lo pasa explícitamente.

Reglas:
- `none`: no escribir archivos al proyecto; devolver reporte inline.
- `engram`: persistir reporte en Engram; no escribir archivos del proyecto.
- `openspec`: escribir `verify-report.md` en el change folder.

## What to Do

1) Completeness: validar que `tasks.md` está completo (o listar pendientes).
2) Correctness: mapear requisitos/escenarios a evidencia en código.
3) Coherence: validar que se siguió el design.
4) Testing (real): correr tests (y build si aplica) y capturar output.
5) Matriz de cumplimiento: escenario → test(s) → resultado.
6) Persistir reporte según mode.

## Rules

- Si tests fallan (exit != 0) → CRITICAL.
- Si un escenario no tiene test → CRITICAL (a menos que el orquestador indique lo contrario).
- No adivinar; basarse en outputs reales.

