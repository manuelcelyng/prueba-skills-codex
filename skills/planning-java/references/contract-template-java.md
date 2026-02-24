# Template de contrato API (Java)

    Usa este formato para `context/hu/<HU_ID>/contrato.md` o el archivo de contrato existente.

    ## Encabezado
    - HU-<ID> - <Titulo corto>

    ## Endpoint
    - Metodo y ruta
    - Headers requeridos (traceId)
    - Path params / Query params

    ## Request
    - DTO
    - Validaciones (Bean Validation y reglas adicionales)
    - Ejemplo JSON

    ## Responses
    - 200 exito con datos (ejemplo JSON)
    - 200 exito sin datos (ejemplo JSON)
    - 400 validacion (ejemplo JSON + estructura de errores)
    - 404 no encontrado (ejemplo JSON)
    - 409 conflicto (si aplica) (ejemplo JSON)
    - 500 error interno (ejemplo JSON)

    ## Codigos de respuesta
    - Mapear `ErrorCode` a HTTP y mensaje en espaniol
    - Actualizar `error-codes.md` si se crean codigos nuevos

    ## Notas OpenAPI
    - `operationId`, tags, ejemplos y textos en espaniol
