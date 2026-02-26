# R-JAVA-013 — Tests mínimos por HU (slices)

## ❌ Mal

- Solo hay un test “end-to-end” frágil, sin unit tests de lógica.
- No hay tests para SQL Provider (riesgo de queries rotos).

## ✅ Bien

- **UseCase**: decisiones de negocio + orquestación.
- **SQL Provider**: estructura/params/cláusulas críticas.
- **Adapter/Gateway**: mapeos + manejo de errores.
- **Handler/Router**: adaptación de request/response (si aplica).
