---
name: planning-java
description: >
  Planifica cambios para servicios Java (Spring Boot WebFlux/R2DBC).
  Trigger: Cuando se requiere contrato HU/API o plan de implementación (incluyendo borrador SQL) antes de desarrollo.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.2"
  scope: [root]
  auto_invoke:
    - "Planificar HU / contrato"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Planear cambios Java y dejar listo el material para que `dev-java` implemente y `review` audite sin ambigüedad.

## Required Context (load order)

1. Leer `AGENTS.md` y `context/` relevante del repo.
2. Leer `./.ai/skills/dev-java/SKILL.md` y `./.ai/skills/review/SKILL.md` como reglas canónicas.
3. Si existe `openspec/changes/<change-name>/`, alinear la HU con `proposal/spec/design/tasks`.
4. Si hay HU, leer `context/hu/<HU_ID>/` y artefactos existentes.
5. Cargar skills locales relevantes (error codes, SQL providers, etc.).
6. Si aplica, consultar ADR/dependencias/ejemplos.

## Output Order (mandatory)

1. Contexto, alcance, supuestos y fuera de alcance.
2. **Contrato API/interfaz** completo.
3. **Plan de implementación** por capas con SQL borrador (o razón explícita si no aplica).
4. Checklist final de “listo para implementar con `dev-java`”.

## Contract Requirements

El contrato debe incluir:
- endpoint/interfaz afectada;
- request/response con validaciones;
- códigos de respuesta y ejemplos JSON para **todas** las respuestas esperadas;
- `ErrorCode`/mensajes si aplica;
- impacto en observabilidad (logs/traceId).

## Implementation Plan Requirements

El plan debe dejar explícito:
- capas afectadas (dominio, use case, adapters, entry points, DTOs, mappers);
- tablas/repositorios/queries involucrados;
- borrador SQL con parámetros nombrados o explicación explícita si no hay SQL;
- constantes, logs, errores y validaciones a tocar;
- estrategia de pruebas por capa.

## Where to Write

- Contrato: `context/hu/<HU_ID>/contrato.md` (o archivo equivalente existente).
- Plan: `context/hu/<HU_ID>/plan-implementacion.md` (o archivo equivalente existente).
- Si el cambio ya usa SDD, reflejar el mismo alcance en `openspec/changes/<change-name>/`.

## References

- `.ai-kit/references/contract-template-java.md`
- `.ai-kit/references/plan-template-java.md`
- `.ai-kit/references/java-api-examples.md`
- `.ai-kit/references/adr-guide.md`
- `.ai-kit/references/dependencies-guide.md`
- `.ai-kit/references/sdd/sdd-playbook.md`

## Limits

- No gestionar git, ramas o PRs.
