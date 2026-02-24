---
name: dev-java
description: >
  Implementa cambios en servicios Java (Spring Boot WebFlux/R2DBC).
  Trigger: Cuando el usuario pida implementar/fix/refactor o agregar endpoints en un servicio Java.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Implementar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Implementar cambios en Java cumpliendo reglas del repo (hexagonal/reactivo, no bloqueos, SQL parametrizado, literales en `Constants`, etc.).

## Required Context (load order)
1. Leer `AGENTS.md`.
2. Leer `.ai-kit/references/context-readme.md`.
3. Leer `.ai-kit/references/java-rules.md`.
3.1. Si aplica HU, revisar `.ai-kit/references/hu-prompts-and-template-usage.md`.
4. Si existe `context/agent-master-context.md`, leerlo completo.
5. Si hay HU, leer `context/hu/<HU_ID>/` y todos los contratos/planes existentes.
6. Si existen, leer: `context/adr_optimized.md`, `context/dependencies_optimized.md`, `context/error-codes.md`, `context/ejemplos-api_optimized.md`, `context/mejores-practicas-calidad-codigo.md`.
7. Si se crea HU/contrato, usar:
   - `.ai-kit/references/hu-context-template.md`
   - `.ai-kit/references/hu-prompts-and-template-usage.md`

## Gate (mandatory)
Verificar que existan:
- Contrato API con codigos de respuesta y ejemplos JSON para todas las respuestas.
- Plan de implementacion con SQL borrador (named params) y cambios por capa.
Si falta alguno, solicitar primero `planning-java` y detener implementacion.

## Workflow

- Seguir el flujo HU/TDD del `context/agent-master-context.md` (si existe).
- Tests mínimos por HU: UseCase, SQL Provider, Adapter, Handler/Router.

## Limits
- No gestionar git, ramas o PRs.

## Resources
- `references/context-map-java.md`
- `references/implementation-checklist-java.md`
