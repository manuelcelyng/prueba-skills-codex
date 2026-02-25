# Review Checklist (ASULADO)

## Java (WebFlux/R2DBC)
- Reactivo end-to-end (sin `.block()`, sin `Thread.sleep`, sin JDBC).
- Hexagonal: dominio sin dependencias infra/Spring; UseCase sin DTOs de API.
- SQL providers con parámetros nombrados (no concatenación).
- Literales (logs/headers/columnas/estados) en `Constants`.
- Errores: `BusinessException` + `ErrorCode` del micro; sin stacktrace al cliente.
- OpenAPI completo (códigos + ejemplos) y textos en español.
- Tests mínimos: UseCase, SQL Provider, Adapter, Handler/Router.

## Python (FastAPI/Lambda)
- Tipado y validación (Pydantic) coherentes con contrato.
- Sin side-effects globales; IO controlado; manejo de errores consistente.
- Tests en `tests/` con `pytest` (happy + errores).

