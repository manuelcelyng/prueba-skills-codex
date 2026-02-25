---
name: planning-java
description: >
  Planifica cambios para servicios Java (Spring Boot WebFlux/R2DBC).
  Trigger: Cuando se requiere contrato HU/API o plan de implementación (incluyendo borrador SQL) antes de desarrollo.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Planificar HU / contrato"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Planear cambios en Java y entregar primero **contrato** y luego **plan de implementación** (SDD).

## Required Context (load order)
1. Leer `AGENTS.md`.
2. Leer `.ai-kit/references/context-readme.md`.
3. Leer `.ai-kit/references/java-rules.md`.
4. Leer `.ai-kit/references/java-playbook.md`.
5. Usar `.ai-kit/references/hu-prompts-and-template-usage.md` como guía SDD.
6. Si hay HU, leer `context/hu/<HU_ID>/`.
7. Si existe un skill local de error codes (ej. `skills/*error-codes*/SKILL.md`), leerlo.
8. Si aplica ADR/deps/ejemplos: cargar `.ai-kit/references/adr-guide.md`, `.ai-kit/references/dependencies-guide.md`, `.ai-kit/references/java-api-examples.md`.

## Output Order (mandatory)
1. Contrato API completo.
2. Plan de implementacion con SQL borrador.
3. Confirmar que el desarrollo puede iniciar con `dev-java`.

## Where to write
- Contrato: `context/hu/<HU_ID>/contrato.md` (o el archivo existente en la HU).
- Plan: `context/hu/<HU_ID>/plan-implementacion.md` (o el archivo existente en la HU).

## Resources
- `.ai-kit/references/contract-template-java.md`
- `.ai-kit/references/plan-template-java.md`

## Limits
- No gestionar git, ramas o PRs.
