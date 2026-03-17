---
name: dev-python
description: >
  Implementa cambios en servicios Python (lambda-* / FastAPI) siguiendo el estándar canónico de SmartPay/ASULADO.
  Trigger: Cuando el usuario pida implementar/fix/refactor o agregar endpoints/tests en un servicio Python.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.4"
  scope: [root]
  auto_invoke:
    - "Implementar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Desarrollo Python (canónico)

Este skill es la **fuente normativa** para implementación Python del kit. `review` debe auditar cualquier cambio Python contra este baseline y contra las reglas locales del repo.

## Shared Operating Model

Antes de codificar, leer `.ai-kit/references/delivery-flow.md` para precedencia, contexto mínimo, gates HU/SDD, write locations y evidencia de cierre.

## Mandatory Reroute

Detén la implementación y redirige cuando aplique:
- si el cambio es no trivial y faltan `proposal/spec/design/tasks` o `contrato + plan`, usar `smartpay-sdd-orchestrator` o `planning-python`;
- si el cambio toca varios micros o mezcla stacks, coordinar con `dev` y/o `smartpay-workspace-router`;
- si el repo tiene reglas locales más estrictas, esas reglas ganan.

## Implementation Workflow

1. Confirmar alcance, interfaz afectada, runtime y dependencias externas.
2. Implementar por lotes pequeños alineados con `tasks.md` o `plan-implementacion.md`.
3. Actualizar pruebas en paralelo.
4. Autoverificar el batch contra el rulebook Python (`PY-ARC-*` a `PY-QLT-*`) antes de seguir.
5. Ejecutar pruebas reales (`pytest`, `black`, `isort`, `mypy`, `ruff` o las del repo) y reportar evidencia.

## Canonical Python Rulebook

La **fuente de verdad obligatoria** es:
- `.ai-kit/references/python-smartpay-rulebook.md`

Durante implementación debes revisar explícitamente estos grupos:
- `PY-ARC-*`: arquitectura, ownership de capas, handlers delgados, ETL y lifecycle.
- `PY-NAM-*`: naming interno en inglés, identificadores descriptivos y type hints.
- `PY-CON-*`: contrato, metadata, wrappers de evento, sanitización y responses.
- `PY-OBS-*`: `trace_id`, logging sin PII y manejo consistente de errores.
- `PY-CFG-*`: env vars, SSM, config centralizada y ausencia de hardcodes operativos.
- `PY-MAP-*`: transforms/mappers puros, validación de DataFrames y normalización centralizada.
- `PY-SQL-*`: acceso a datos en `extract/load/repositories`, queries seguras y lifecycle del engine.
- `PY-TST-*`: `pytest`, cobertura de handlers/trace lifecycle, tests por capa y criterio sobre mappers triviales.
- `PY-RUN-*`: `pyproject.toml`, runtime/manifests (`template.yaml`, `samconfig*`, `k8s`, `Dockerfile`) y compatibilidad de versión Python.
- `PY-QLT-*`: cleanup, tamaño de handlers, no mutar inputs compartidos y evidencia real de checks.

### Mandatory implementation lens
- Respeta la arquitectura real del repo (`extract/transform/load` o `domain/application/infrastructure`) y deja el handler/router solo como boundary.
- Normaliza metadata y wrappers del contrato en helpers dedicados; no inventes metadata operativa con valores hardcodeados.
- Logging con `trace_id`, sin secretos/PII ni payloads completos.
- Configuración sensible/operativa solo por env vars/settings/SSM; nombres en inglés y ligados al dominio.
- En SQL, parametriza valores, deja queries en las capas dueñas y controla el lifecycle del engine/conexiones.
- Los transforms/mappers con lógica deben ser puros, validar entradas y devolver resultados explícitos aun cuando no haya datos.
- Testing mínimo: happy path + error path relevante, y coverage directa de handler/trace lifecycle si el boundary fue tocado.

## Done Criteria

Antes de cerrar el cambio confirma:
- contrato/specs siguen alineados con la implementación y con `PY-CON-*`;
- configuración, runtime y documentación quedaron consistentes con `PY-CFG-*` y `PY-RUN-*`;
- pruebas y checks reales fueron ejecutados conforme a `PY-TST-*` y `PY-QLT-*`;
- reportas archivos tocados, pruebas ejecutadas y cualquier desviación del plan.

## References
- `.ai-kit/references/delivery-flow.md`
- `.ai-kit/references/python-smartpay-rulebook.md`
- `.ai-kit/references/python-smartpay-reference.md`
- `.ai-kit/references/sdd/sdd-playbook.md`
