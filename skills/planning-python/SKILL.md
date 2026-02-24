---
name: planning-python
description: Planifica cambios para servicios Python del workspace ASULADO (lambda-*, motor-reglas-liquidacion). Usar para scoping/HU/contratos Python; debe generar contrato con codigos y ejemplos JSON y luego plan de implementacion con SQL antes del desarrollo.
metadata:
  scope: root
  auto_invoke:
    - "Planificar HU / contrato"
---

# Planificacion Python

Usa este skill para planear cambios en servicios Python del workspace.

## Carga de contexto obligatoria
1. Leer `AGENTS.md`.
2. Leer `.ai-kit/references/context-readme.md`.
3. Leer `.ai-kit/references/python-rules.md`.
4. Leer `AGENTS.md` del servicio si existe; si no existe, leer `README.md`.
5. Si existe `context/reglas-desarrollo.md`, leerlo completo.
6. Si existe `context/actualizacion-python-3.12.md`, leerlo cuando la tarea toque versiones o dependencias.
7. Si hay HU, leer `context/hu/<HU_ID>/` y contratos/planes existentes.
8. Si hay guias de tests (`tests/README.md`) o arquitectura (`src/app/README.md`), leerlas cuando apliquen.
9. En servicios FastAPI, leer `pyproject.toml` y guias de migraciones si existen.

## Orden de entrega obligatorio
1. Contrato de interfaz.
2. Plan de implementacion con SQL borrador o explicacion si no aplica SQL.
3. Confirmar que el desarrollo puede iniciar con `dev-python`.

## Contrato de interfaz (archivo en la HU)
- Guardar en `context/hu/<HU_ID>/contrato.md` o el nombre que ya exista en la HU.
- Si el servicio expone HTTP (FastAPI), definir contrato API con ruta, metodo, headers, request/response, codigos y ejemplos JSON.
- Si es Lambda/ETL, definir contrato de evento (payload de entrada, esquema, campos obligatorios) y el resultado esperado (salida, SQS, DB) con codigos de respuesta o estados logicos.
- Incluir ejemplos JSON para cada variante (exito, error, validacion).
- Mantener mensajes en espaniol si hay respuesta al usuario.

## Plan de implementacion (archivo en la HU)
- Guardar en `context/hu/<HU_ID>/plan-implementacion.md` o el nombre que ya exista en la HU.
- Objetivo, alcance, modulos y archivos afectados.
- Flujo por capas (extract/transform/load o domain/application/infrastructure).
- SQL o consultas usadas (named params). Si no hay SQL, explicar el mecanismo de persistencia.
- Validaciones, logging con trace_id y configuracion/env vars.
- Plan de pruebas (pytest) y cobertura objetivo.
- Impacto en SAM/K8s/pyproject si cambia runtime o dependencias.

## Reglas transversales
- Seguir la arquitectura y estilo del servicio.
- No hardcode de secretos; usar env/SSM.
- Formato con black/isort/mypy segun `pyproject.toml`.

## Limites
- No gestionar git, ramas o PRs.

## Referencias
    - `references/contract-template-python.md`
    - `references/plan-template-python.md`
