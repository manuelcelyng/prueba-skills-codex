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
  version: "0.1"
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
4. Leer `.ai-kit/references/gitlab-mr-review-commenting.md`.
5. Cargar solo el diff del MR y el contexto mínimo de los archivos tocados.

## Python Review Tags (mandatory)

Como `dev-python` no define IDs formales por regla, este skill usa los siguientes tags estables para comentar:

- `PY-ARC`: arquitectura y separación de capas.
- `PY-CONTRACT`: contrato, validación y payloads.
- `PY-OBS`: logging, errores y trazabilidad.
- `PY-CONFIG`: configuración, secretos y seguridad.
- `PY-SQL`: persistencia y SQL seguro.
- `PY-STYLE`: estilo, tipado, formato y mantenibilidad.
- `PY-TEST`: cobertura, `pytest`, fixtures y evidencia real.
- `PY-CLEAN`: cleanup, duplicación, side-effects globales y código muerto.

## Workflow

1. Validar que el MR sea principalmente Python.
2. Revisar primero el diff, no el repo completo.
3. Traducir cada hallazgo a uno de los tags `PY-*`.
4. Emitir comentarios inline solo para hallazgos accionables y verificables.
5. Cada comentario debe:
   - estar en **español**,
   - ser **objetivo, claro y amable**,
   - citar el **tag** incumplido,
   - explicar el **impacto**,
   - y mostrar un **ejemplo corto** solo cuando realmente ayude a corregir más rápido.
6. Cierra con un comentario resumen del MR.
7. Usa **formato corto** si el comentario queda inline en el diff.
8. Usa **formato medio** si el hallazgo debe ir como nota general del MR.

## What to review

Prioriza incumplimientos de:

- `PY-ARC`: handlers/routers con lógica de negocio o capas mezcladas.
- `PY-CONTRACT`: payloads/validaciones desalineadas con el contrato.
- `PY-OBS`: manejo deficiente de errores o falta de `trace_id`.
- `PY-CONFIG`: secretos hardcodeados o configuración fuera de env/settings.
- `PY-SQL`: queries inseguras o acceso a datos inconsistente.
- `PY-STYLE`: ausencia de type hints, formato o convenciones del repo.
- `PY-TEST`: falta de `pytest`, fixtures o evidencia de ejecución.
- `PY-CLEAN`: código muerto, side-effects globales, duplicación, funciones gigantes.

## Mandatory Comment Rules

- Un hallazgo por comentario.
- No usar comentarios ambiguos como “mejorar esto”.
- No comentar observaciones subjetivas sin impacto técnico.
- Mantener tono humano y cordial: directo, técnico y respetuoso; evitar sonar robótico o regañón.
- Si el comentario es inline, mantenerlo corto.
- Si el comentario es general del MR, dejarlo en formato medio: archivo, línea, problema, impacto y sugerencia.
- El ejemplo es opcional; incluirlo solo cuando reduzca ambigüedad o acelere la corrección.
- Si el hallazgo es repetido, comentar el caso representativo y mencionar el patrón.
- Si no puedes comentar inline directamente en GitLab por falta de integración/herramienta, genera comentarios listos para pegar manteniendo el mismo formato.

## Comment Format

Usa siempre el formato de `.ai-kit/references/gitlab-mr-review-commenting.md`.

Ejemplo mínimo esperado:

```md
[P2][PY-CONFIG] Secreto hardcodeado en código productivo

Ojo aquí con `PY-CONFIG`: el valor sensible quedó embebido en el módulo en vez de resolverse desde configuración/env vars.
Impacto: dificulta la rotación de credenciales y expone secretos en el código.
Sugerencia: mueve el valor a `settings` o variable de entorno y consúmelo desde la configuración central del servicio.

Ejemplo sugerido:
```python
api_token = settings.notifications_api_token
```
```

## Limits

- No aprobar por ausencia de comentarios si falta evidencia de tests/checks.
- No inventar tags fuera del catálogo `PY-*`.
- No usar inglés en los comentarios del MR.

## References

- `skills/review/SKILL.md`
- `skills/dev-python/SKILL.md`
- `.ai-kit/references/gitlab-mr-review-commenting.md`
