# Mapa de contexto Python (ASULADO)

    Usa este mapa para ubicar reglas y archivos fuente antes de implementar.

    ## Servicios Python
    - `lambda-recepcion-pagos/`
    - `lambda-pagos-liquidacion/`
    - `lambda-liquidacion-dispersion/`
    - `lambda-smartpay-notificacion/`
    - `motor-reglas-liquidacion/`

    ## Contexto comun (kit)
    - `.ai-kit/references/context-readme.md`
    - `.ai-kit/references/python-rules.md`

    ## Contexto por servicio
    - `<servicio>/AGENTS.md` (si existe)
    - `<servicio>/context/reglas-desarrollo.md` (si existe)
    - `<servicio>/context/actualizacion-python-3.12.md` (si existe)
    - `<servicio>/context/hu/<HU_ID>/` (si aplica)
    - `tests/README.md` o `src/app/README.md` cuando existan

    ## Notas especiales
    - `lambda-smartpay-notificacion` y `motor-reglas-liquidacion` no tienen `context/` propio.
    - Validar version de Python en `pyproject.toml` o `template.yaml` antes de cambiar dependencias.
