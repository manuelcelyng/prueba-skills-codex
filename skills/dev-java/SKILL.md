---
name: dev-java
description: >
  Implementa cambios en servicios Java (Spring Boot WebFlux/R2DBC) siguiendo el estándar canónico de SmartPay/ASULADO.
  Trigger: Cuando el usuario pida implementar/fix/refactor o agregar endpoints/tests en un servicio Java.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.3"
  scope: [root]
  auto_invoke:
    - "Implementar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Desarrollo Java (canónico)

Este skill es la **fuente normativa** para implementación Java del kit. Si `review` detecta una desviación contra estas reglas, la implementación debe corregirse.

## Shared Operating Model

Antes de codificar, leer `.ai-kit/references/delivery-flow.md` para:
- precedencia de reglas;
- contexto mínimo a cargar;
- gate obligatorio entre planning ↔ implementación ↔ review;
- ubicación de artefactos HU/SDD y evidencia esperada al cierre.

## Mandatory Reroute

Detén la implementación y redirige cuando aplique:
- si el cambio es no trivial y faltan `proposal/spec/design/tasks` o `contrato + plan`, usar `smartpay-sdd-orchestrator` o `planning-java`;
- si el cambio toca varios micros, coordinar también con `smartpay-workspace-router` o con el flow multi-micro del workspace;
- si el repo tiene reglas locales más estrictas, esas reglas ganan.

## Implementation Workflow

1. Confirmar alcance, criterios de aceptación, capa(s) afectadas y artefacto funcional vigente.
2. Implementar por lotes pequeños siguiendo `tasks.md` o `plan-implementacion.md`.
3. Actualizar tests en paralelo; no dejar testing para el final.
4. Autoverificar el batch contra las secciones 1-8 de este skill antes de seguir.
5. Ejecutar pruebas reales (`./gradlew test`, slices o comando equivalente del repo) y reportar evidencia.

## Canonical Java Rulebook

### 1) Arquitectura y ownership de capas
- Mantener arquitectura hexagonal/clean: **Domain → UseCase → Infrastructure → Entry Points**.
- El dominio no depende de Spring ni de infraestructura.
- Los UseCases orquestan puertos; no dependen de DTOs API ni de adapters concretos.
- Los adapters implementan puertos, hacen mapeos y acceso técnico; no contienen reglas de negocio.
- Routers/handlers validan/adaptan entrada-salida, manejan `traceId` y delegan el negocio al UseCase.

### 2) Naming, lenguaje y estructura
- Código, clases, métodos y nombres internos en inglés.
- Logs, mensajes funcionales y Swagger/OpenAPI en español.
- Puertos del dominio con sufijo `Port` o `Gateway`; evitar `*Repository` para puertos de dominio.
- En HUs nuevas evita nombres genéricos como `execute`, `Get*` o `Query*`; el nombre del UseCase debe reflejar intención.
- Para adapters evita nombres mezclados como `RepositoryAdapter`; usa nombres concretos al dominio.
- Evita FQCN inline dentro del código; importa al inicio.

### 3) Modelo reactivo (Reactor/WebFlux)
- Prohibido `.block()`, `Thread.sleep`, JDBC, I/O bloqueante o `subscribe()` manual en lógica de negocio.
- No anidar suscripciones ni esconder side-effects dentro de `map`.
- Evita `collectList()` + `Flux::fromIterable` cuando el objetivo es seguir procesando; prefiere streaming con `concatMap` o `flatMap` controlado.
- En procesos por lote, define explícitamente si un error por elemento aborta todo o se gestiona por item; no lo dejes implícito.

### 4) Persistencia, queries y SQL
- Si la consulta es simple, prefiere derived query en `ReactiveCrudRepository`/`CrudRepository`.
- Si es intermedia y legible, `@Query` es aceptable.
- Si es compleja, usa `DatabaseClient` y/o `SQLProvider`.
- SQL siempre con parámetros nombrados; nunca concatenes input del usuario.
- En SQL Providers usa una query base clara y agrega filtros opcionales con `append` controlado.
- Usa alias explícitos y legibles en `SELECT`; para columnas derivadas o calculadas prefiere alias en `snake_case`.
- Centraliza strings técnicos reutilizados (bind names, columnas, headers, estados, claves) en constantes cuando aparezcan en más de un punto.

### 5) Mapping, modelos y validación
- MapStruct o mappers solo mapean; no llevan lógica de negocio.
- En adapters R2DBC, el mapeo `row -> modelo` debe delegarse en `*RowMapper` cuando el repo siga ese patrón.
- Los modelos de dominio no deben usar sufijo `Row`; los modelos de lectura/mapeo viven en infraestructura.
- Validaciones de entrada en DTOs con Bean Validation y el mecanismo del repo (`ValidatorEngine`, translators, etc.).
- Evita validaciones manuales en handlers/usecases salvo reglas puramente de negocio.

### 6) Contrato, errores, logs y constantes
- Mantén alineados router, handler, OpenAPI, DTOs y tests con el contrato aprobado.
- Toda respuesta esperada debe tener código y ejemplo JSON en el contrato/HU o en el spec activo.
- Los errores funcionales se modelan con `BusinessException` + `ErrorCode` del micro.
- Si se agrega o cambia un error funcional, actualiza también el catálogo/documentación del micro cuando exista (por ejemplo `error-codes.md`).
- Logs en español, sin PII, con `traceId` como primer dato de correlación.
- No concatenes strings con `+` en logs; usa placeholders.
- Literales repetidos o de negocio deben vivir en `Constants` o clases equivalentes.

### 7) Testing mínimo obligatorio
- Por HU o task relevante, cubrir como mínimo: UseCase + SQL Provider + Adapter + Handler/Router, según aplique al cambio.
- En unit tests, el SUT debe usar `@InjectMocks` y las dependencias `@Mock`; evita `@Spy` salvo necesidad técnica real.
- Centraliza datos en `*TestData`, Object Mother o fixtures equivalentes; no hardcodees estados ni valores de negocio inestables inline.
- Para Reactor usa `StepVerifier`; para API reactiva usa `WebTestClient` si el repo lo usa.
- En tests de SQL valida cláusulas críticas y mapa de parámetros, no el SQL completo literal.

### 8) Cleanup y mantenibilidad
- Elimina código muerto, DTOs, mappers, rutas, tests, constantes y helpers sin uso después del refactor.
- No dejes código comentado ni `@SuppressWarnings` sin justificación técnica acotada.
- Evita duplicación, magic numbers, imports wildcard, métodos gigantes y métodos con demasiados parámetros cuando la estructura pida extraer objetos.
- No dejes deuda invisible: si la implementación requiere ADR o ajuste documental, déjalo explícito en los artefactos del cambio.

## Done Criteria

Antes de cerrar el cambio confirma:
- contrato/specs siguen alineados con la implementación;
- pruebas relevantes pasan con evidencia real;
- no quedan strings técnicos regados, código muerto ni atajos reactivos incorrectos;
- reportas archivos tocados, pruebas ejecutadas y cualquier desviación del plan.

## References
- `.ai-kit/references/delivery-flow.md`
- `.ai-kit/references/java-smartpay-reference.md`
- `.ai-kit/references/sdd/sdd-playbook.md`

