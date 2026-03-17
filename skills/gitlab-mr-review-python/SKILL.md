---
name: gitlab-mr-review-python
description: >
  Revisa Merge Requests Python directamente en GitLab usando el baseline
  canónico (`review` + `dev-python`) y deja comentarios inline en español,
  objetivos, accionables y con tono humano/amigable, con regla incumplida,
  impacto y ejemplo de corrección.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.2"
  scope: [root]
  auto_invoke:
    - "Revisar MR Python en GitLab"
    - "Comentar hallazgos Python en GitLab MR"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# GitLab MR Review Python

## Purpose

Revisar código Python en Merge Requests y comentar **directamente en GitLab** los incumplimientos reales contra las reglas canónicas del kit.

Este skill adapta la auditoría de `review` al contexto de comentarios inline en MR para servicios Python.

## Required Context (load order)

1. Leer `AGENTS.md`.
2. Leer `skills/review/SKILL.md`.
3. Leer `skills/dev-python/SKILL.md`.
4. Leer `.ai-kit/references/python-smartpay-rulebook.md`.
5. Leer `.ai-kit/references/gitlab-mr-review-commenting.md`.
6. Cargar solo el diff del MR y el contexto mínimo de los archivos tocados.

## Python Review Rule IDs (mandatory)

Este skill debe comentar usando **IDs formales del rulebook**, no tags genéricos:

- `PY-ARC-*`: arquitectura, handlers, ownership de capas, ETL y lifecycle.
- `PY-NAM-*`: naming interno, inglés, type hints y convenciones Python.
- `PY-CON-*`: contrato, validación, metadata y payloads.
- `PY-OBS-*`: logging, `trace_id`, errores y observabilidad.
- `PY-CFG-*`: configuración, secretos, env vars y ausencia de hardcodes operativos.
- `PY-MAP-*`: mapping, normalización y transformaciones puras.
- `PY-SQL-*`: persistencia y SQL seguro.
- `PY-TST-*`: `pytest`, cobertura y estrategia de pruebas.
- `PY-RUN-*`: runtime, manifests y packaging.
- `PY-QLT-*`: cleanup, mutaciones in-place, tamaño del handler y evidencia real.

## Workflow

1. Validar que el MR sea principalmente Python.
2. Revisar primero el diff, no el repo completo.
3. Revisar las discusiones existentes del MR antes de comentar.
4. Traducir cada hallazgo a un **ID concreto** del rulebook `PY-*`.
5. Emitir comentarios inline solo para hallazgos accionables y verificables.
6. Si ya existe un comentario sobre el mismo punto:
   - no duplicarlo si ya está completo,
   - complétalo en el mismo hilo si le falta regla/tag, impacto o sugerencia,
   - y solo abre un hilo nuevo si el problema no está cubierto.
7. Cada comentario debe:
   - estar en **español**,
   - ser **objetivo, claro y amable**,
   - citar la **regla** incumplida,
   - explicar el **impacto**,
   - y mostrar un **ejemplo corto** solo cuando realmente ayude a corregir más rápido.
8. Cierra con un comentario resumen del MR.
9. Usa **formato corto** si el comentario queda inline en el diff.
10. Usa **formato medio** si el hallazgo debe ir como nota general del MR.
11. Si complementas un comentario ya existente, responde en ese mismo hilo con el mismo tono y agrega únicamente el contexto faltante.

## What to review

Prioriza incumplimientos de:

- `PY-ARC-*`: handlers/routers con lógica de negocio, ETL o capas mezcladas.
- `PY-CON-*`: payloads, metadata o validaciones desalineadas con el contrato.
- `PY-OBS-*`: lifecycle deficiente de `trace_id`, logs con PII/payloads crudos o manejo ambiguo de errores.
- `PY-CFG-*`: secretos, `path`, `key`, `url`, queue names, endpoints o metadata operativa hardcodeados, o configuración fuera de env/settings/SSM.
- `PY-MAP-*`: transforms/mappers con side effects, sin validación de inputs o con lógica fuera de su capa.
- `PY-SQL-*`: queries inseguras, acceso a datos fuera de `extract/load/repositories` o lifecycle incorrecto de engine/conexiones.
- `PY-NAM-*`: nombres internos en español, identificadores ambiguos o ausencia de type hints relevantes.
- `PY-TST-*`: falta de `pytest`, fixtures, edge cases o evidencia de ejecución.
- `PY-RUN-*`: `pyproject.toml`, `template.yaml`, `samconfig*`, lifecycle FastAPI o runtime desalineados con el cambio.
- `PY-QLT-*`: código muerto, mutaciones in-place innecesarias, duplicación o handlers gigantes.

## Mandatory Comment Rules

- Un hallazgo por comentario.
- No usar comentarios ambiguos como “mejorar esto”.
- No comentar observaciones subjetivas sin impacto técnico.
- Mantener tono humano y cordial: directo, técnico y respetuoso; evitar sonar robótico o regañón.
- Si el comentario es inline, mantenerlo corto.
- Si el comentario es general del MR, dejarlo en formato medio: archivo, línea, problema, impacto y sugerencia.
- Si ya hay un comentario correcto pero incompleto, complétalo en vez de duplicarlo.
- El ejemplo es opcional; incluirlo solo cuando reduzca ambigüedad o acelere la corrección.
- Si el hallazgo es repetido, comentar el caso representativo y mencionar el patrón.
- Si no puedes comentar inline directamente en GitLab por falta de integración/herramienta, genera comentarios listos para pegar manteniendo el mismo formato.

## Comment Format

Usa siempre el formato de `.ai-kit/references/gitlab-mr-review-commenting.md`.

Ejemplo mínimo esperado:

```md
[P2][PY-CFG-002] Queue URL hardcodeada en código productivo

Ojo aquí: la queue quedó fija en código en vez de resolverse desde configuración/env vars.
Impacto: acopla el despliegue a un ambiente puntual y complica rotación/configuración entre QA, PDN o local.
Sugerencia: muévela a settings o variable de entorno y consúmela desde la configuración central del servicio.

Ejemplo sugerido:
```python
queue_url = settings.notifications_queue_url
```
```

## Limits

- No aprobar por ausencia de comentarios si falta evidencia de tests/checks.
- No inventar reglas fuera del catálogo `PY-*` del rulebook.
- No usar inglés en los comentarios del MR.

## References

- `skills/review/SKILL.md`
- `skills/dev-python/SKILL.md`
- `.ai-kit/references/python-smartpay-rulebook.md`
- `.ai-kit/references/gitlab-mr-review-commenting.md`
