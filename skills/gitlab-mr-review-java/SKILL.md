---
name: gitlab-mr-review-java
description: >
  Revisa Merge Requests Java directamente en GitLab usando el baseline canónico
  (`review` + `dev-java` + rulebook Java), y deja comentarios inline en
  español, objetivos y accionables, con regla incumplida, impacto y ejemplo de
  corrección.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Revisar MR Java en GitLab"
    - "Comentar hallazgos Java en GitLab MR"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# GitLab MR Review Java

## Purpose

Revisar código Java en Merge Requests y comentar **directamente en GitLab** los incumplimientos reales contra las reglas canónicas del kit.

Este skill es un specialization layer de `review`: no redefine las reglas Java, sino que adapta su salida al formato de comentarios inline de GitLab.

## Required Context (load order)

1. Leer `AGENTS.md`.
2. Leer `skills/review/SKILL.md`.
3. Leer `skills/dev-java/SKILL.md`.
4. Leer `.ai-kit/references/java-smartpay-rulebook.md`.
5. Leer `.ai-kit/references/gitlab-mr-review-commenting.md`.
6. Cargar solo el diff del MR y el contexto mínimo de los archivos tocados.

## What to review

Prioriza incumplimientos de:

- `J-ARC-*`, `J-NAM-*`: arquitectura, ownership y naming.
- `J-REA-*`: errores de composición reactiva, bloqueos, `subscribe()` manual, excepciones fuera del pipeline.
- `J-API-*`, `J-ERR-*`: responses auditables, `BusinessException`, `ErrorCode`, logs y trazabilidad.
- `J-MAP-*`, `J-SQL-*`: MapStruct, mapping entre capas, SQL y repositorios.
- `J-TST-*`, `J-QLT-*`, `J-DOC-*`: pruebas, cleanup y evidencia documental.

## Workflow

1. Validar que el MR sea principalmente Java.
2. Revisar primero el diff, no el repo completo.
3. Emitir comentarios inline solo para hallazgos accionables y verificables.
4. Cada comentario debe:
   - estar en **español**,
   - ser **objetivo y claro**,
   - citar la **regla** incumplida,
   - explicar el **impacto**,
   - y mostrar un **ejemplo corto** de cómo corregir.
5. Si un patrón se repite, comenta el caso más representativo y menciona que el problema aparece en más lugares.
6. Cierra con un comentario resumen del MR.

## Mandatory Comment Rules

- Un hallazgo por comentario.
- No comentar nits subjetivos ni preferencias personales.
- No dejar comentarios genéricos como “revisar esto” o “mejorar naming”.
- Si el problema no es suficientemente claro para el autor, el comentario está mal redactado.
- Si no puedes comentar inline directamente en GitLab por falta de integración/herramienta, genera comentarios listos para pegar manteniendo el mismo formato.

## Comment Format

Usa siempre el formato de `.ai-kit/references/gitlab-mr-review-commenting.md`.

Ejemplo mínimo esperado:

```md
[P1][J-REA-006] Excepción fuera del flujo reactivo

Se está incumpliendo `J-REA-006` porque la serialización JSON se ejecuta en un `try/catch` que lanza la excepción antes de retornar el `Mono`.
Impacto: el error sale del pipeline y no podrá ser capturado por operadores reactivos posteriores.
Sugerencia: mueve la serialización a `Mono.fromCallable(...)` y mapea el error con `onErrorMap(...)`.

Ejemplo sugerido:
```java
return Mono.fromCallable(() -> objectMapper.writeValueAsString(dto))
    .onErrorMap(JsonProcessingException.class,
        ex -> new BusinessException(ErrorCode.ERROR_PUBLISHING_MESSAGE, traceId))
    .flatMap(payload -> publisher.send(payload));
```
```

## Limits

- No aprobar por ausencia de comentarios si falta evidencia de tests/build.
- No comentar hallazgos no sustentados por una regla o por el diff.
- No mezclar múltiples reglas en un mismo hilo.
- No usar inglés en los comentarios del MR.

## References

- `skills/review/SKILL.md`
- `skills/dev-java/SKILL.md`
- `.ai-kit/references/java-smartpay-rulebook.md`
- `.ai-kit/references/gitlab-mr-review-commenting.md`

