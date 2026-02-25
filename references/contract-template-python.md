# Plantilla de Contrato (Python)

## 1) Contexto
- HU / objetivo
- Supuestos y out-of-scope

## 2) Tipo de interfaz
Elegir uno:
- HTTP (FastAPI)
- Evento (Lambda/SQS/SNS)
- Batch/ETL

## 3) Contrato
### HTTP
- Método + path
- Headers requeridos (incluye `trace_id`/correlación si aplica)
- Query params / path vars
- Request body (schema + validaciones)
- Responses por HTTP (código + `codigoRespuesta` + mensaje ES + ejemplo JSON)

### Evento
- Evento/payload de entrada (schema, campos obligatorios)
- Salida esperada (DB/SQS/HTTP) y estados lógicos
- Errores esperados + mapeos (si aplica)

## 4) Observabilidad
- Logging con `trace_id`/correlación (sin PII)
- Métricas/eventos si aplica

## 5) Criterios de aceptación
- Casos felices
- Casos de error (validación, not found, externo, interno)

