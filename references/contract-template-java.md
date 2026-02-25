# Plantilla de Contrato (Java)

## 1) Contexto
- HU / objetivo
- Supuestos y out-of-scope

## 2) Endpoints
Por endpoint:
- Método + path
- Headers requeridos (incluye `traceId` si aplica)
- Query params / path vars
- Request body (schema + validaciones)

## 3) Responses
Por código HTTP:
- `codigoRespuesta` (ErrorCode/SuccessCode)
- `mensaje` (ES)
- Ejemplo JSON completo

## 4) Errores
- Catálogo de `ErrorCode` a usar (prefijo del micro)
- Tabla: `ErrorCode` → HTTP → mensaje base → condición de disparo

## 5) Observabilidad
- Logs inicio/fin y errores (sin PII)
- Campos mínimos de correlación (`traceId`)

## 6) Criterios de aceptación
- Casos felices
- Casos de error (validación, not found, externo, interno)

