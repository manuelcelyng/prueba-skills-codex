---
name: dev-java
description: >
  Implementa cambios en servicios Java (Spring Boot WebFlux/R2DBC) siguiendo el estándar canónico de SmartPay/ASULADO.
  Trigger: Cuando el usuario pida implementar/fix/refactor o agregar endpoints/tests en un servicio Java.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.5"
  scope: [root]
  auto_invoke:
    - "Implementar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Desarrollo Java (canónico)

Este skill es la **fuente normativa** para implementación Java del kit. La lectura obligatoria para una tarea Java es:
1. `.ai-kit/references/delivery-flow.md`
2. `.ai-kit/references/java-smartpay-rulebook.md`
3. `.ai-kit/references/java-smartpay-reference.md` (solo si necesitas contrato/plan/ejemplos)

## Mandatory Reroute

Detén la implementación y redirige cuando aplique:
- si el cambio es no trivial y faltan `proposal/spec/design/tasks` o `contrato + plan`, usar `smartpay-sdd-orchestrator` o `planning-java`;
- si el cambio toca varios micros, coordinar también con `smartpay-workspace-router` o con el flow multi-micro del workspace;
- si el repo tiene reglas locales más estrictas, esas reglas ganan.

## Implementation Workflow

1. Confirmar alcance, criterios de aceptación, capa(s) afectadas y artefacto funcional vigente.
2. Implementar por lotes pequeños siguiendo `tasks.md` o `plan-implementacion.md`.
3. Actualizar tests en paralelo; no dejar testing para el final.
4. Autoverificar el batch contra el rulebook Java antes de seguir.
5. Ejecutar pruebas reales (`./gradlew test`, slices o comando equivalente del repo) y reportar evidencia.

## Critical Non-Negotiables

- `J-ARC-002`: los puertos del dominio usan siempre sufijo `Port`; `Gateway` no se usa.
- `J-NAM-006`: los `Port` también se nombran por entidad/capacidad, no por verbo o proceso.
- `J-NAM-002`: el nombre del `UseCase` debe describir modelo/capacidad, no un verbo imperativo.
- `J-NAM-003`: el método público del UseCase no se llama `execute`.
- `J-NAM-005`: clases utilitarias y `*TestData` deben usar `@UtilityClass`.
- `J-API-001`: toda respuesta debe salir por un builder/utilitario auditable.
- `J-API-003`: validaciones en español indicando el campo funcional.
- `J-MAP-001` y `J-MAP-002`: mappings entre capas con MapStruct; no hardcodear builders cross-layer inline en el flujo.
- `J-REA-002`: prohibido bloquear flujos reactivos.
- `J-ERR-001`: errores funcionales con `BusinessException` + `ErrorCode`.
- `J-QLT-002`: no dejar comentarios/código comentado como soporte de claridad.
- `J-QLT-006` y `J-QLT-007`: evitar wrappers sin comportamiento y configuración/beans sin consumidor real.
- `J-TST-001`: trabajar con baseline TDD.
- `J-TST-003`: método de test en inglés; `@DisplayName` en español.

## Done Criteria

Antes de cerrar el cambio confirma:
- contrato/specs siguen alineados con la implementación;
- pruebas relevantes pasan con evidencia real;
- no quedan strings técnicos regados, código muerto ni atajos reactivos incorrectos;
- reportas archivos tocados, pruebas ejecutadas y cualquier desviación del plan.

## References
- `.ai-kit/references/delivery-flow.md`
- `.ai-kit/references/java-smartpay-rulebook.md`
- `.ai-kit/references/java-smartpay-reference.md`
- `.ai-kit/references/sdd/sdd-playbook.md`
