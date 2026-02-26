# R-JAVA-011 — Contrato OpenAPI (códigos + ejemplos)

## ❌ Mal

- Solo define `200` y omite códigos de error.
- No tiene ejemplos JSON (request/response).

## ✅ Bien

- Define todos los códigos relevantes (`200/201/400/404/409/422/500`, etc. según el caso).
- Incluye ejemplo JSON por **cada** respuesta.

Referencia: `contract-template-java.md` + `java-api-examples.md`.
