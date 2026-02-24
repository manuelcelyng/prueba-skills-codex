# Checklist de revision

    ## Documentacion y planning
    - Existe contrato con codigos de respuesta y ejemplos JSON para todas las respuestas.
    - Existe plan de implementacion con SQL borrador o explicacion si no aplica SQL.
    - El contrato precede al plan dentro de la HU.
    - `error-codes.md` actualizado si aplica.
    - ADR o `dependencies_optimized.md` actualizado si aplica.

    ## Java
    - Arquitectura hexagonal respetada.
    - Reactividad end-to-end sin bloqueos.
    - Literales en `Constants` y logs en espaniol con traceId.
    - `BusinessException` + `ErrorCode`.
    - SQL Providers con named params.
    - MapStruct sin negocio en mappers/adapters/routers.
    - Tests por capa completos.

    ## Python
    - Arquitectura segun servicio.
    - Logging con `trace_id`.
    - Sin hardcode de secretos.
    - Formato y checks (black/isort/mypy).
    - Version de Python correcta.
    - Tests y cobertura >=80% cuando aplica.
