---
name: pr-description
description: >
  Escribe descripciones de Pull Request / Merge Request siguiendo el formato
  estándar del kit. Úsalo al crear un PR/MR, redactar su descripción o cuando
  el usuario pida resumir cambios para peer review.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Escribir descripción de PR"
    - "Resumir cambios para Pull Request"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# PR Description

## Purpose

Generar descripciones de Pull Request / Merge Request claras, breves y consistentes para el flujo del AI Kit, orientadas a que el reviewer entienda rápido qué cambió, por qué cambió y dónde enfocar la revisión.

## Required Context

1. Leer `AGENTS.md` del repo actual.
2. Verificar la rama actual y el branch base del PR.
3. Obtener el diff completo del branch con `git diff main...HEAD`.
4. Si `main` no existe en el repo local, usar `origin/main...HEAD`.
5. Si el PR va contra otra rama base y el usuario lo indica explícitamente, usar esa rama como base y mencionarlo.
6. Si hay evidencia clara en el diff o en el contexto, identificar pruebas, cambios de contrato, config, migrations, archivos renombrados/eliminados y cualquier punto sensible para peer review.

## Workflow

1. Ejecutar `git diff main...HEAD` para inspeccionar todos los cambios del branch.
2. Revisar nombres de archivos, renames y deletions relevantes.
3. Agrupar los cambios por tema funcional, no por orden de archivo.
4. Redactar la descripción final usando exactamente este formato:

```md
## What
One sentence explaining what this PR does.

## Why
Brief context on why this change is needed

## Changes
- Bullet points of specific changes made
- Group related changes together
- Mention any files deleted or renamed
```

## Writing Rules

- `What` debe ser una sola oración, directa y orientada al resultado.
- `Why` debe explicar el motivo funcional o técnico sin repetir `What`.
- `Changes` debe listar solo cambios concretos y relevantes.
- Agrupa bullets relacionados en vez de repetir un bullet por archivo si hacen parte del mismo ajuste.
- Menciona explícitamente archivos o carpetas renombradas/eliminadas cuando aplique.
- Si hay tests agregados/ajustados, validaciones manuales, cambios de contrato, configsecret, migrations, jobs o scripts operativos, menciónalos dentro de `Changes`.
- Si existe un punto sensible para review (por ejemplo: cambio de contrato, comportamiento reactivo, SQL, config o riesgo de compatibilidad), déjalo explícito en un bullet corto dentro de `Changes`.
- No inventes contexto que no esté respaldado por el diff o por el usuario.
- Si el cambio toca varios dominios, prioriza el impacto funcional antes del detalle técnico.
- Si el usuario no pide otro idioma, redacta la descripción en inglés porque es el formato base compartido por el equipo.
- Mantén foco en peer review: la descripción debe ayudar a revisar, no solo a narrar commits.

## Reviewer Focus

Cuando aplique, prioriza mencionar en `Changes`:

- contratos API/eventos que cambiaron,
- validaciones nuevas o endurecidas,
- cambios en persistencia/queries/migrations,
- config/env vars/manifests,
- archivos eliminados o renombrados,
- pruebas agregadas o ajustadas.

## Output

Devuelve únicamente la descripción final lista para pegar en el Pull Request, salvo que el usuario pida además un análisis o variantes.
