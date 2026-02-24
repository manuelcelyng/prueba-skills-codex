---
name: dev-python
description: Implementa cambios en servicios Python del workspace ASULADO (lambda-*, motor-reglas-liquidacion). Usar para desarrollo, fixes o pruebas en Python; seguir contextos raiz y del servicio.
metadata:
  scope: root
  auto_invoke:
    - "Implementar cambios"
---

# Desarrollo Python

Usa este skill para implementar cambios en servicios Python del workspace.

## Carga de contexto obligatoria (antes de escribir codigo)
1. Leer `AGENTS.md`.
2. Leer `.ai-kit/references/context-readme.md`.
3. Leer `.ai-kit/references/python-rules.md`.
4. Leer `AGENTS.md` del servicio si existe; si no existe, leer `README.md`.
5. Si existe `context/reglas-desarrollo.md`, leerlo completo.
6. Si existe `context/actualizacion-python-3.12.md`, leerlo cuando la tarea toque versiones o dependencias.
7. Si hay HU, leer `context/hu/<HU_ID>/` y contratos/planes existentes.
8. Si hay guias de tests (`tests/README.md`) o arquitectura (`src/app/README.md`), leerlas cuando apliquen.

## Inventario de contextos Python (para ubicar reglas)
- `lambda-recepcion-pagos/context`: `reglas-desarrollo.md`, `actualizacion-python-3.12.md`, `hu/`.
- `lambda-pagos-liquidacion/context`: `reglas-desarrollo.md`, `hu/`.
- `lambda-liquidacion-dispersion`: sin `context/`.
- `lambda-smartpay-notificacion`: sin `context/` (usar `AGENTS.md` y `README.md`).
- `motor-reglas-liquidacion`: sin `context/` (usar `AGENTS.md`, `pyproject.toml`, `k8s/` si aplica).

## Gate obligatorio de planificacion
Verificar que existan:
- Contrato de interfaz con codigos de respuesta y ejemplos JSON para todas las respuestas.
- Plan de implementacion con SQL borrador o explicacion explicita si no aplica SQL.
Si falta alguno, solicitar primero `planning-python` y detener implementacion.

## Reglas criticas (resumen)
- Respetar la arquitectura del servicio segun su `AGENTS.md` y contexto local.
- En Lambdas ETL, mantener separacion `extract/`, `transform/`, `load/`, `utils/`, `config/` y entry point en `src/lambda_handler.py`.
- En `lambda-smartpay-notificacion`, separar `domain`, `application`, `infrastructure` y mantener handlers delgados.
- En `motor-reglas-liquidacion`, usar arquitectura hexagonal, routers FastAPI delgados y type hints obligatorios.
- Logging estructurado con `trace_id` y helpers `set_trace_id`, `get_trace_id`, `clear_trace_id` donde existan.
- Configuracion y secretos por env/SSM; no hardcode.
- Formato y checks: `black`, `isort`, `mypy` segun `pyproject.toml`.
- Usar la version de Python definida en cada servicio (`pyproject.toml` o `template.yaml`).

## Flujo de implementacion
- Descomponer por capas, implementar cambios pequenos y tests en paralelo.
- Documentar cambios de contrato, SQL o configuracion en la HU.
- Actualizar documentacion y configs (SAM/K8s) si cambia el runtime o variables.

## Pruebas minimas
- Pytest con naming estandar.
- Cobertura objetivo >80% cuando aplique.

## Limites
- No gestionar git, ramas o PRs.

## Referencias
    - `references/context-map-python.md`
    - `references/implementation-checklist-python.md`
