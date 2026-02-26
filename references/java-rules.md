# Reglas Java (SmartPay) — estándar único (Hexagonal + Reactivo)

Este archivo es la **fuente de verdad única** para reglas Java del kit.
Otros documentos (checklists, quality notes) **no deben duplicar reglas**: deben enlazar a secciones/IDs aquí.

> Convención: cada regla tiene un ID `R-JAVA-###` y enlaza a un ejemplo con “❌ mal / ✅ bien”.

## Índice (reglas con ejemplos)

| ID | Regla (resumen) | Ejemplo |
|---|---|---|
| R-JAVA-001 | Respetar capas Hexagonal/Clean (dominio puro, use cases orquestan, infra implementa puertos, entrypoints adaptan) | `java-examples/R-JAVA-001-hexagonal.md` |
| R-JAVA-002 | Reactivo end-to-end (WebFlux/R2DBC), prohibido bloquear (`.block()`, `Thread.sleep`, JDBC) | `java-examples/R-JAVA-002-non-blocking.md` |
| R-JAVA-003 | Reactor “bien usado”: sin `subscribe()` manual, sin side-effects en `map`, sin anidar suscripciones | `java-examples/R-JAVA-003-reactor-operators.md` |
| R-JAVA-004 | No materializar para reemitir: evitar `collectList()` + `Flux::fromIterable`; preferir streaming (`concatMap` si secuencial/ordenado) | `java-examples/R-JAVA-004-streaming-over-collect.md` |
| R-JAVA-005 | Batch robusto: manejar errores por elemento (`onErrorResume` por item/lote) para que un fallo no aborte todo | `java-examples/R-JAVA-005-batch-errors.md` |
| R-JAVA-006 | Queries simples: derived query por nombre (`findAllBy...`) > `@Query` (intermedio) > `DatabaseClient/SQLProvider` (complejo) | `java-examples/R-JAVA-006-derived-queries.md` |
| R-JAVA-007 | SQL Providers: parámetros nombrados, base query completa + `append` para filtros opcionales, sin concatenar input | `java-examples/R-JAVA-007-sql-providers.md` |
| R-JAVA-008 | Literales (logs/headers/columnas/estados) a `Constants` del dominio (no hardcode repetido) | `java-examples/R-JAVA-008-constants.md` |
| R-JAVA-009 | Logging: español, sin PII, `traceId` primero, placeholders (no `+`) | `java-examples/R-JAVA-009-logging.md` |
| R-JAVA-010 | Errores: `BusinessException` + `ErrorCode` del micro; entrypoint no expone stacktraces | `java-examples/R-JAVA-010-errors.md` |
| R-JAVA-011 | Contrato API: OpenAPI con códigos + ejemplos JSON para **todas** las respuestas | `java-examples/R-JAVA-011-openapi-contract.md` |
| R-JAVA-012 | UseCases: evitar métodos genéricos como `execute`; usar nombre de intención | `java-examples/R-JAVA-012-usecase-naming.md` |
| R-JAVA-013 | Tests mínimos por HU: UseCase + SQL Provider + Adapter + Handler/Router (según aplique) | `java-examples/R-JAVA-013-test-slices.md` |
| R-JAVA-014 | Tests: sin hardcode de negocio; centralizar en `*TestData` / Object Mother | `java-examples/R-JAVA-014-testdata.md` |
| R-JAVA-015 | `*TestData` como utility consistente (ej. `@UtilityClass`) + nombres descriptivos (evitar `b1/b2`) | `java-examples/R-JAVA-015-testdata-utility.md` |
| R-JAVA-016 | Clean code: no duplicación, no magic numbers, no código comentado, no `import *` | `java-examples/R-JAVA-016-clean-code.md` |
| R-JAVA-017 | E2E LocalStack (SQS): el cliente debe apuntar al endpoint correcto; aislar cambios solo-local | `java-examples/R-JAVA-017-localstack-sqs.md` |
| R-JAVA-018 | Tests de SQL: validar cláusulas críticas + mapa de params (no comparar SQL completo) | `java-examples/R-JAVA-018-sql-provider-tests.md` |
| R-JAVA-019 | Dependencias: justificar, compatibilidad Java 21/WebFlux/R2DBC, ADR si es estratégico | `java-examples/R-JAVA-019-dependencies.md` |

## 1) Arquitectura y capas (R-JAVA-001)

- Hexagonal/Clean: **Dominio → UseCase → Infraestructura → Entry Points**.
- Dominio sin dependencias de Spring/infra; UseCase solo usa puertos.
- Infra implementa puertos + mapea DTO/entidades a dominio.
- Entry points: validan input, manejan `traceId`, invocan use case, adaptan respuesta.
- Ningún adapter/mapper/router debe contener reglas de negocio.

## 2) Reactividad (R-JAVA-002 a R-JAVA-005)

- Prohibido bloquear (`.block()`, `Thread.sleep`, JDBC).
- Preferir composición de operadores Reactor; evitar `subscribe()` manual en lógica de negocio.
- Evitar materializar para reemitir (`collectList()` + `fromIterable`).
- En batch: errores por elemento (no abortar el proceso completo).

## 3) Persistencia (R2DBC) (R-JAVA-006 a R-JAVA-007, R-JAVA-018)

- Queries simples: derived query por nombre.
- Queries intermedias: `@Query` (si queda legible).
- Queries complejas: `DatabaseClient`/SQL Providers.
- SQL Providers:
  - parámetros nombrados (bind), nunca concatenar input
  - query base completa + `append` solo para filtros opcionales
  - tests: cláusulas críticas + params (no SQL completo)

## 4) API y contratos (R-JAVA-011)

- OpenAPI con:
  - códigos de respuesta (incluyendo errores)
  - ejemplos JSON de **todas** las respuestas
- Mensajes/Swagger en español.
  - Plantillas: `contract-template-java.md`, `plan-template-java.md`.

## 5) Errores (R-JAVA-010)

- Modelar errores como `BusinessException` + `ErrorCode` del micro.
- El entrypoint traduce a respuesta estándar (sin stacktrace).
- Mantener catálogo de error codes (skill local o doc del micro).

## 6) Constantes y logging (R-JAVA-008 a R-JAVA-009)

- Literales repetidos a `Constants` (dominio).
- Logging:
  - español, sin PII
  - `traceId` como primer argumento
  - placeholders (no concatenación con `+`)

## 7) Nomenclatura (R-JAVA-012)

- Código (clases/métodos) en inglés; logs/mensajes/Swagger en español.
- Evitar `execute()` en UseCases; preferir intención (más legible en trazas/review).
- Sufijos habituales: `UseCase`, `Port/Gateway`, `Adapter`, `SQLProvider`, `Mapper`, `Handler`, `Router`.

## 8) Testing (R-JAVA-013 a R-JAVA-015)

- Stack: JUnit 5, Mockito, Reactor Test (StepVerifier), WebTestClient (si aplica), ArchUnit (si existe).
- Tests mínimos por HU: UseCase + SQL Provider + Adapter + Handler/Router (según aplique).
- Tests sin hardcode de negocio; centralizar en `*TestData`.

## 9) Calidad / Review (R-JAVA-016)

- Evitar: duplicación, magic numbers, código comentado, métodos enormes, `import *`.
- Sin lógica de negocio en mappers/adapters/routers.

## 10) E2E (LocalStack) (R-JAVA-017)

- Además de crear colas/recursos, el cliente debe apuntar al endpoint correcto.
- Aislar ajustes solo-local (perfil/config/stash) para no contaminar prod.

## Related references

- Playbook (flujo HU/TDD): `java-playbook.md`
- Ejemplos de contrato JSON: `java-api-examples.md`
- Dependencias: `dependencies-guide.md`
