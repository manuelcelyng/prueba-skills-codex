---
name: planning-java
description: >
  Planifica cambios para servicios Java (Spring Boot WebFlux/R2DBC).
  Trigger: Cuando se requiere contrato HU/API o plan de implementación (incluyendo borrador SQL) antes de desarrollo.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.5"
  scope: [root]
  auto_invoke:
    - "Planificar HU / contrato"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Planning Java

Planear cambios Java y dejar listo el material para que `dev-java` implemente y `review` audite sin ambigüedad.

## Shared Operating Model

Leer primero:
1. `.ai-kit/references/delivery-flow.md`
2. `.ai-kit/references/java-smartpay-rulebook.md`
3. `.ai-kit/references/java-smartpay-reference.md`

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
- `ErrorCode`, mensajes, auditoría y observabilidad relevante.

## Implementation Plan Requirements

El plan debe anticipar el rulebook Java:
- `J-ARC-*`: capas afectadas, ownership, puertos `Port`, paso del input por validator en el boundary, baseline común de `reactive-web`, dominio como source of truth y ausencia de modelos request/response dentro del dominio;
- `J-NAM-*`: nombres de UseCase/modelos/`Port` consistentes con la capacidad, no con verbos genéricos, atributos/variables/métodos descriptivos en inglés y utilitarios/`*TestData` declarados como `@UtilityClass`;
- `J-API-*`: auditoría de responses, validaciones con campo, traceabilidad y contrato real;
- `J-MAP-*`: mappers MapStruct y lugares donde no se debe construir objetos cross-layer inline;
- `J-REA-*`: composición fluida del pipeline, errores técnicos mapeados dentro del flujo, evitar materialización innecesaria y preferir operadores reactivos sobre loops imperativos;
- `J-SQL-*`: estrategia de persistencia/query y borrador SQL parametrizado;
- `J-ERR-*`: constantes, logs y catálogo de errores a tocar;
- `J-TST-*`: estrategia de pruebas por capa, baseline TDD, convención método inglés + `@DisplayName` en español y criterio explícito para no planear tests aislados de mappers 1-a-1 ya cubiertos indirectamente, reservándolos para transformaciones no triviales;
- `J-QLT-*`: riesgos de smells, comments, wrappers artificiales y configuración/beans sin consumidor a evitar desde el diseño.

## Handoff to Implementation

No marques el planning como listo si falta alguno de estos puntos:
- contrato con ejemplos JSON suficientes;
- plan técnico por capas;
- tratamiento de errores, auditoría y trazabilidad;
- borrador SQL o justificación de ausencia;
- estrategia de mapping, tests y cleanup verificable.

## References
- `.ai-kit/references/delivery-flow.md`
- `.ai-kit/references/java-smartpay-rulebook.md`
- `.ai-kit/references/java-smartpay-reference.md`
- `.ai-kit/references/sdd/sdd-playbook.md`
