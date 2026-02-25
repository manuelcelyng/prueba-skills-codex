# Ejemplos de Contrato API (JSON)

## Purpose
Plantillas de request/response para mantener consistencia entre HUs/servicios.

## Request paginado (ejemplo)
```json
{"pagina":1,"tamano":10,"filtros":{"estado":"APROBADO"}}
```

## Response éxito (estructura base)
```json
{
  "resultado": true,
  "datos": {
    "paginacion": {
      "pagina": 1,
      "tamano": 10,
      "filtros": {"estado": "APROBADO"},
      "totalRegistros": 100,
      "totalPaginas": 10
    },
    "registros": [
      {"idLote":1,"estado":"APROBADO"}
    ]
  },
  "errores": null,
  "codigoRespuesta": "00",
  "mensaje": "Consulta exitosa",
  "fechaHora": "2025-11-08T12:00:00",
  "idTrazabilidad": "abc-123"
}
```

## Response error (estructura base)
```json
{
  "resultado": false,
  "datos": null,
  "errores": [
    {"campo": "pagina", "mensaje": "La página debe ser mayor que cero"}
  ],
  "codigoRespuesta": "VAL-001",
  "mensaje": "Error de validación",
  "fechaHora": "2025-11-08T12:05:00",
  "idTrazabilidad": "def-456"
}
```

## Reglas mínimas
1. Incluir `idTrazabilidad` para correlación.
2. `errores` es lista de `{campo, mensaje}`.
3. En error: `datos=null`. En éxito: `errores=null`.

