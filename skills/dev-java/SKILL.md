---
name: dev-java
description: >
  Implementa cambios en servicios Java (Spring Boot WebFlux/R2DBC).
  Trigger: Cuando el usuario pida implementar/fix/refactor o agregar endpoints en un servicio Java.
license: Internal
metadata:
  author: pragma-smartpay
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
4. Leer `.ai-kit/references/java-playbook.md`.
5. Si aplica HU, revisar `.ai-kit/references/hu-prompts-and-template-usage.md`.
6. Si hay HU, leer `context/hu/<HU_ID>/` y todos los contratos/planes existentes.
7. Si existe un skill local de error codes (ej. `skills/*error-codes*/SKILL.md`), leerlo.
8. Si necesitas ejemplos o checklist: cargar `.ai-kit/references/java-api-examples.md` y `.ai-kit/references/java-rules.md` (IDs `R-JAVA-*` + ejemplos).

## Gate (mandatory)
Verificar que existan:
- Contrato API con codigos de respuesta y ejemplos JSON para todas las respuestas.
- Plan de implementacion con SQL borrador (named params) y cambios por capa.
Si falta alguno, solicitar primero `planning-java` y detener implementacion.

## Workflow

- Seguir el flujo HU/TDD de `.ai-kit/references/java-playbook.md`.
- Tests mínimos por HU: UseCase, SQL Provider, Adapter, Handler/Router.
- Naming:
  - Evitar métodos llamados `execute` en UseCases; usar nombres descriptivos que indiquen claramente la funcionalidad.
- Queries:
  - Si el query es simple, preferir derived query en `ReactiveCrudRepository`/`CrudRepository` (resolver por nombre).
  - Si el query es complejo, permitir `DatabaseClient`/SQL Providers; si es intermedio y legible, `@Query`.
- Reactor:
  - Evitar `collectList()` + `Flux::fromIterable` solo para reemitir y continuar el flujo; preferir streaming (`concatMap` si secuencial/ordenado).
  - En flujos por lote, manejar errores por elemento (`onErrorResume` por item/lote) para que un fallo no aborte el proceso completo.

## Limits
- No gestionar git, ramas o PRs.

## Resources
- `.ai-kit/references/java-playbook.md`
- `.ai-kit/references/java-rules.md`
- `.ai-kit/references/java-api-examples.md`
