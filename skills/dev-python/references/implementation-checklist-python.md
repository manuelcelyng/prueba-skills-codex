# Checklist de implementacion Python

    ## Gate previo
    - Existe contrato con codigos de respuesta y ejemplos JSON para todas las respuestas.
    - Existe plan de implementacion con SQL borrador o explicacion si no aplica SQL.
    - Si falta alguno, pedir `planning-python` y detener desarrollo.

    ## Flujo recomendado
    1. Identificar arquitectura del servicio (ETL, FastAPI, hexagonal).
    2. Definir cambios por capa (extract/transform/load o domain/application/infrastructure).
    3. Implementar en pasos pequenos con tests en paralelo.
    4. Log estructurado con `trace_id` y helpers cuando existan.
    5. Actualizar configuracion (SAM/K8s/env) si cambia runtime o vars.
    6. Ejecutar pruebas (`pytest`) y validar cobertura objetivo.

    ## Reglas no negociables
    - No hardcode de secretos; usar env/SSM.
    - Formato con black/isort/mypy segun `pyproject.toml`.
