---
name: <skill-name>
description: >
  <1-2 líneas: qué hace y para quién>.
  Trigger: <cuándo se debe invocar>.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "<Acción estable 1>"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

<Qué problema resuelve este skill y qué resultados produce.>

## Required Context (load order)
1. Leer `AGENTS.md`.
2. Leer `.ai-kit/references/context-readme.md`.
3. Cargar solo los contextos/HUs que apliquen.

## Workflow

- <Paso 1>
- <Paso 2>
- <Paso 3>

## Limits

- No gestionar git, ramas o PRs.

