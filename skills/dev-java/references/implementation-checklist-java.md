# Checklist de implementacion Java

    ## Gate previo
    - Existe contrato con codigos de respuesta y ejemplos JSON para todas las respuestas.
    - Existe plan de implementacion con SQL borrador (named params) y cambios por capa.
    - Si falta alguno, pedir `planning-java` y detener desarrollo.

    ## Flujo recomendado (TDD)
    1. Identificar capas impactadas (dominio, usecase, infraestructura, entry points).
    2. Diseñar modelos y puertos de dominio (sin Spring).
    3. Crear tests por capa: UseCase, SQL Provider, Adapter, Handler/Router.
    4. Implementar UseCase.
    5. Implementar SQL Provider y Adapter (sin negocio en infraestructura).
    6. Implementar mappers MapStruct.
    7. Implementar Handler/Router + OpenAPI.
    8. Centralizar literales en `Constants` y mensajes/logs en espaniol.
    9. Mapear errores a `BusinessException` + `ErrorCode`.
    10. Actualizar `error-codes.md` y ADRs si aplica.

    ## Reglas no negociables
    - WebFlux + R2DBC end-to-end; no bloqueos (`.block()`, JDBC).
    - Codigo en ingles; logs y Swagger en espaniol.
    - SQL con parametros nombrados, sin concatenar input.
