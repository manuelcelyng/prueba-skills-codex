# R-JAVA-017 — LocalStack + SQS (endpoint correcto)

## ❌ Mal (solo crea colas, pero el cliente apunta a AWS real)

- Se crean colas en LocalStack, pero el `SqsAsyncClient`/`SqsClient` no tiene `endpointOverride`.
- Resultado: tests “pasan” o “fallan” de forma no determinista, o tocan recursos reales.

## ✅ Bien (endpointOverride + config aislada)

- Configurar el cliente para apuntar al endpoint de LocalStack (solo en perfil/test).
- Aislar cambios “solo local” (perfil/config/stash) para no contaminar prod.
