# Review Checklist (ASULADO)

## Java (WebFlux/R2DBC)
- Reactivo end-to-end (sin `.block()`, sin `Thread.sleep`, sin JDBC).
- Reactor: evitar `collectList()` + `Flux::fromIterable` solo para reemitir; preferir streaming (`concatMap` si secuencial/ordenado).
- Batch: en flujos por lote, manejar errores por elemento (`onErrorResume` por item/lote) para que un fallo no aborte el proceso completo.
- Hexagonal: dominio sin dependencias infra/Spring; UseCase sin DTOs de API.
- SQL providers con parámetros nombrados (no concatenación).
- Queries simples: preferir derived queries por nombre en repos R2DBC (`findAllBy...`) antes de `@Query`/`DatabaseClient`.
- UseCases: evitar métodos genéricos como `execute`; usar nombres descriptivos de intención.
- Literales (logs/headers/columnas/estados) en `Constants`.
- Errores: `BusinessException` + `ErrorCode` del micro; sin stacktrace al cliente.
- OpenAPI completo (códigos + ejemplos) y textos en español.
- Tests mínimos: UseCase, SQL Provider, Adapter, Handler/Router.
- Tests: evitar data hardcodeada (ej. estados) y centralizar constantes/fixtures en `*TestData`.
- LocalStack E2E: el cliente SQS debe apuntar al endpoint correcto; aislar cambios “solo local” para no contaminar prod.

## Python (FastAPI/Lambda)
- Tipado y validación (Pydantic) coherentes con contrato.
- Sin side-effects globales; IO controlado; manejo de errores consistente.
- Tests en `tests/` con `pytest` (happy + errores).
