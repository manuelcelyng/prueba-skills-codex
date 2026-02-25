# Plantilla de Plan de Implementación (Python)

## 1) Scope técnico
- Componentes/módulos afectados
- Cambios por capas (si aplica): domain/application/infrastructure o extract/transform/load

## 2) Datos e integración
- Contratos consumidos/producidos
- Persistencia (SQL o equivalente) + named params si hay SQL
- Variables de entorno / configuración

## 3) Manejo de errores
- Excepciones y mapeos a respuesta/estado
- Estrategia de retries/timeouts (si aplica)

## 4) Tests
- Pytest: escenarios (happy + errores)
- Fixtures/mocks y cobertura objetivo

## 5) Validación
- Comandos (`pytest`, `ruff/black/mypy` si aplica)
- Riesgos (runtime/deps/perf/seguridad)

