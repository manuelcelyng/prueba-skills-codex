# Reglas Python (Lambda/ETL y microservicios)

## Estructura y arquitectura
- Entry point Lambda: `src/lambda_handler.py`.
- ETL con separacion clara: `extract/`, `transform/`, `load/`, `utils/`, `config/`.
- Tests en `tests/` replican estructura de `src/app/`.

## Logging y trace
- Logging estructurado con `trace_id`.
- Usar helpers `set_trace_id`, `get_trace_id`, `clear_trace_id`.
- `LOG_LEVEL` se define por variable de entorno.

## Configuracion
- Parametros no sensibles en `samconfig*.yaml`.
- Secretos via Parameter Store/SSM (no hardcode, no commits).

## Estilo y herramientas
- Indentacion 4 espacios; `snake_case` funciones/variables; `PascalCase` clases.
- Formato y checks:
  - `python -m black src tests`
  - `python -m isort src tests`
  - `python -m mypy src`
- Usa la version de Python definida en cada `pyproject.toml`.

## Pruebas
- Framework: pytest.
- Convenciones: `test_*.py`, `Test*`, `test_*`.
- Marcadores: `unit`, `integration`, `slow`, `database`.
- Cobertura objetivo >80% (cuando aplique).

## Deploy (SAM)
- Runtime y handler definidos en `template.yaml`.
- VPC y parametros definidos por ambiente.

## Practicas de equipo
- Commits: mensaje corto, en minusculas, estilo imperativo.
- MR: resumen, notas de pruebas (comandos + resultados), links a issues.
- Si cambian `samconfig-*.yaml`, mencionarlo explicitamente.

