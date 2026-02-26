# Review Checklist (ASULADO)

## Java (WebFlux/R2DBC)
Fuente de verdad: `java-rules.md` (IDs `R-JAVA-001` a `R-JAVA-019`).

Checklist rápido (sin duplicar reglas):
- Arquitectura/capas: `R-JAVA-001`
- Reactividad/streaming/batch: `R-JAVA-002`..`R-JAVA-005`
- Persistencia/SQL: `R-JAVA-006`..`R-JAVA-007`, `R-JAVA-018`
- Errores/logging/constantes: `R-JAVA-008`..`R-JAVA-010`
- Contratos: `R-JAVA-011`
- Naming UseCases: `R-JAVA-012`
- Tests/TestData: `R-JAVA-013`..`R-JAVA-015`
- Clean code: `R-JAVA-016`
- E2E LocalStack: `R-JAVA-017`

## Python (FastAPI/Lambda)
- Tipado y validación (Pydantic) coherentes con contrato.
- Sin side-effects globales; IO controlado; manejo de errores consistente.
- Tests en `tests/` con `pytest` (happy + errores).
