---
name: dev-java
description: >
  Implementa cambios en servicios Java (Spring Boot WebFlux/R2DBC) siguiendo el estándar canónico de SmartPay/ASULADO.
  Trigger: Cuando el usuario pida implementar/fix/refactor o agregar endpoints/tests en un servicio Java.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.6"
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
- `J-ARC-004`: el input entra por el boundary y pasa por validator/Bean Validation antes de orquestar el `UseCase`.
- `J-ARC-006`: el baseline de `reactive-web` es común para todos los microservicios Java del workspace; no se rompe por micro sin desviación aprobada.
- `J-ARC-007`: el modelo de dominio es la fuente de verdad del negocio; DTOs, entities, messages y ViewModels se mapean desde/hacia dominio sin mover lógica de negocio fuera de él.
- `J-ARC-008`: en dominio no existen modelos de request/response; esos contratos viven en aplicación/interfaz y se convierten con mapeadores fuera del dominio.
- `J-NAM-006`: los `Port` se nombran por el modelo/capacidad de la entidad que representan, no por verbo o proceso.
- `J-NAM-002`: el nombre del `UseCase` debe describir modelo/capacidad, no verbos ni sufijos de flujo como `Registration`.
- `J-NAM-007`: abstracciones reutilizables (mensajería/auditoría/publicación) se nombran por capacidad genérica, no por contextos transitorios como `Novelty`.
- `J-NAM-003`: el método público del UseCase no se llama `execute`.
- `J-NAM-005`: clases utilitarias y `*TestData` deben usar `@UtilityClass`.
- `J-NAM-008` y `J-NAM-009`: atributos, variables, parámetros y métodos deben ser completamente descriptivos, en inglés y alineados al dominio; no usar `x`, `tmp`, `obj`, `data` ni equivalentes ambiguos.
- `J-API-001`: toda respuesta debe salir por un builder/utilitario auditable.
- `J-API-003`: validaciones en español indicando el campo funcional.
- `J-ARC-005`: colaboradores técnicos siempre por inyección; no `INSTANCE` ni instancias manuales en flujo productivo.
- `J-API-006`: cuando el entry point cambie path/shape, deben alinearse también tests, contrato, curls y artefactos funcionales asociados.
- `J-MAP-001`, `J-MAP-002` y `J-MAP-005`: mappings entre capas con MapStruct; no hardcodear builders cross-layer inline y los mappers de infraestructura deben ser Spring-managed.
- `J-REA-002`: prohibido bloquear flujos reactivos.
- `J-REA-005`: la respuesta principal del endpoint sale del flujo principal; lo asíncrono queda aislado como side effect técnico.
- `J-REA-006`: serialización/mapping/parsing que puede fallar debe quedar dentro del pipeline reactivo (`Mono.fromCallable`/`Mono.defer` + `onErrorMap`); si el error es controlado, debe mapearse a `BusinessException`.
- `J-REA-007`: cuando varias operaciones pertenecen al mismo modelo/contexto, compón el flujo con encadenamiento fluido y no fragmentes el pipeline en métodos que oculten la lectura del proceso.
- `J-REA-008`: evita `collectList()`/`Flux.fromIterable()` cuando el flujo puede seguir streaming; usa límites, paginación, buffering acotado y backpressure.
- `J-REA-009`: dentro de código reactivo prefiere operadores del pipeline sobre `for`, `for-each`, `while` o acumulaciones manuales.
- `J-ERR-001`: errores funcionales con `BusinessException` + `ErrorCode`.
- `J-QLT-002`: no dejar comentarios/código comentado como soporte de claridad.
- `J-QLT-006`, `J-QLT-007` y `J-QLT-008`: evitar wrappers sin comportamiento, configuración/beans sin consumidor real y `configsecret`/manifests con `path`, `key`, `url` o endpoints hardcodeados; esas variables deben salir de env vars en inglés y con naming semántico del dominio.
- `J-TST-001`: trabajar con baseline TDD.
- `J-SQL-004` y `J-SQL-006`: `snake_case` solo para aliases SQL cuando mejore el mapping; repositorios R2DBC simples permanecen delgados (`R2dbcRepository`).
- `J-TST-003`, `J-TST-006`, `J-TST-007` y `J-TST-008`: método de test en inglés y camelCase, `@DisplayName` en español, Mockito estándar, `TestData`, parametrización cuando aplique y sin tests aislados de config/mappers 1-a-1 sin valor funcional; si un mapper tiene lógica, transformación o normalización no trivial, sí debe probarse de forma específica.

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
