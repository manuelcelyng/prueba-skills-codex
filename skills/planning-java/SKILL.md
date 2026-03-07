---
name: planning-java
description: >
  Planifica cambios para servicios Java (Spring Boot WebFlux/R2DBC).
  Trigger: Cuando se requiere contrato HU/API o plan de implementación (incluyendo borrador SQL) antes de desarrollo.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.3"
  scope: [root]
  auto_invoke:
    - "Planificar HU / contrato"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Planning Java

Planear cambios Java y dejar listo el material para que `dev-java` implemente y `review` audite sin ambigüedad.

## Shared Operating Model

Leer `.ai-kit/references/delivery-flow.md` antes de producir artefactos. Ese documento define contexto mínimo, gates HU/SDD, write locations y evidencia esperada para pasar a implementación y review.

## Deliverables (mandatory order)

1. Contexto, alcance, supuestos y fuera de alcance.
2. **Contrato API/interfaz** completo.
3. **Plan de implementación** por capas con borrador SQL o razón explícita de por qué no aplica.
4. Checklist final de “listo para implementar con `dev-java`”.

## Contract Requirements

El contrato debe dejar explícito:
- endpoint o interfaz afectada;
- headers/correlación (`traceId` si aplica);
- request/response con validaciones;
- códigos de respuesta y ejemplos JSON para **todas** las respuestas esperadas;
- `ErrorCode`, mensajes y observabilidad relevante.

## Implementation Plan Requirements

El plan debe anticipar la taxonomía que `dev-java` y `review` van a exigir:
- capas afectadas: Domain, UseCase, Infrastructure, Entry Points, DTOs, mappers;
- puertos nuevos o extendidos y su intención;
- estrategia de persistencia/query (`derived query`, `@Query`, `DatabaseClient`/`SQLProvider`) con justificación;
- borrador SQL con parámetros nombrados o explicación explícita si no hay SQL;
- constantes, logs, catálogo de errores y validaciones a tocar;
- estrategia de pruebas por capa: UseCase, SQL Provider, Adapter, Handler/Router;
- impacto en dependencias o ADRs cuando aplique.

## Handoff to Implementation

No marques el planning como listo si falta alguno de estos puntos:
- contrato con ejemplos JSON suficientes;
- plan técnico por capas;
- tratamiento de errores y trazabilidad;
- borrador SQL o justificación de ausencia;
- estrategia de pruebas verificable.

## References
- `.ai-kit/references/delivery-flow.md`
- `.ai-kit/references/java-smartpay-reference.md`
- `.ai-kit/references/sdd/sdd-playbook.md`

