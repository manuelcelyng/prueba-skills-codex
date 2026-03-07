---
name: review
description: >
  Revisa cambios y valida cumplimiento de reglas, contrato/plan o artefactos SDD, usando dev-java/dev-python como estándar canónico.
  Trigger: Cuando el usuario pida code review, auditoría técnica o validación de HU/checklists.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.2"
  scope: [root]
  auto_invoke:
    - "Revisar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Este skill es la **fuente canónica de review** del kit. Su trabajo es contrastar cambios contra:
- reglas del repo,
- reglas canónicas de implementación (`dev-java` / `dev-python`),
- contrato + plan o artefactos SDD,
- evidencia real de pruebas/build cuando corresponda.

## Source of truth (precedencia)

1. `AGENTS.md` y contexto local del repo.
2. Skills overlay del micro (`./skills/*`) que apliquen.
3. Artefactos funcionales aprobados: `openspec/changes/<change>/...` o `context/hu/<HU_ID>/...`.
4. `./.ai/skills/dev-java/SKILL.md` o `./.ai/skills/dev-python/SKILL.md` según el stack.
5. Este skill (formato y checklist de auditoría).

## Required Context (load order)

1. Leer `AGENTS.md` y el contexto local relevante.
2. Determinar stack y leer el skill canónico correspondiente (`dev-java` o `dev-python`).
3. Leer skills locales relevantes (error codes, SQL providers, etc.).
4. Leer HU/contrato/plan o artefactos SDD (`proposal/spec/design/tasks`).
5. Revisar diff, archivos tocados y, si existen, resultados de pruebas/build.

## Review Workflow

1. Validar primero el **proceso**: ¿hay artefactos suficientes para justificar el cambio?
2. Revisar después el **cumplimiento técnico** por stack.
3. Verificar por último la **evidencia real**: pruebas, build, cobertura o comandos corridos.
4. Emitir hallazgos ordenados por severidad y con referencias concretas.

## Output (mandatory)

1. **Hallazgos** primero, ordenados por severidad.
2. Para hallazgos puntuales usar `::code-comment{...}` con archivo y líneas.
3. Luego listar **preguntas / supuestos / faltantes de contexto**.
4. Cerrar con un **resumen corto** del estado general.

## Mandatory Process Checks

Reporta hallazgo de proceso cuando aplique:
- Cambio no trivial sin `proposal/spec/design/tasks` ni `contrato + plan`.
- Implementación que contradice el contrato/specs aprobados.
- Cambio que introduce error codes/dependencias/decisiones sin actualizar evidencia documental cuando el repo lo exige.
- Cambio “listo para merge” sin evidencia real de tests/build.

## Java Review Checklist

### Arquitectura y diseño
- Respeta Domain → UseCase → Infrastructure → Entry Points.
- No hay lógica de negocio en mappers, adapters, routers o handlers.
- Los puertos del dominio no usan nombres `*Repository` si el repo exige `Port/Gateway`.
- Nuevos UseCases evitan nombres genéricos (`execute`, `Get*`, `Query*`) y reflejan intención.

### Reactividad y flujo
- No hay `.block()`, `Thread.sleep`, JDBC, `subscribe()` manual ni side-effects en `map`.
- No se usa `collectList()` + `Flux::fromIterable` solo para reemitir y seguir el flujo.
- En lotes, el manejo de errores por item es coherente con el caso de negocio.

### Persistencia y SQL
- La estrategia de query es razonable: derived query / `@Query` / SQL Provider según complejidad.
- SQL con parámetros nombrados; sin concatenar input del usuario.
- `SELECT` con alias explícitos y legibles; alias derivados en `snake_case` cuando aplique.
- Mapeo R2DBC delegado en `*RowMapper` si el repo sigue ese patrón.
- No hay strings técnicos repetidos dispersos (bind names, columnas, claves, headers, estados) cuando debieron centralizarse.

### Contrato, validación y errores
- Router/handler/DTO/OpenAPI/tests siguen el contrato aprobado.
- Todas las respuestas relevantes tienen código + ejemplo JSON en contrato/spec/HU.
- Validaciones de entrada viven en DTO/validator del repo; no hay validación manual dispersa sin motivo.
- Errores funcionales modelados con `BusinessException` + `ErrorCode`.

### Logging, constantes y calidad
- Logs en español, sin PII, con `traceId` como correlación principal.
- No hay concatenación con `+` en logs.
- Literales repetidos o de negocio fueron extraídos a constantes.
- No quedaron imports wildcard, FQCN inline, código comentado, `@SuppressWarnings` injustificados ni código muerto.

### Testing
- El cambio trae cobertura suficiente por capa: UseCase + SQL Provider + Adapter + Handler/Router según aplique.
- Se usa `@InjectMocks` para el SUT y `@Mock` para dependencias en unit tests.
- Los tests usan `*TestData`/fixtures reutilizables; no hardcodean estados ni valores de negocio.
- Los tests de SQL validan cláusulas críticas y mapa de parámetros.
- Hay evidencia real de ejecución (`./gradlew test`, slices o build relevante).

## Python Review Checklist

### Arquitectura y contrato
- Respeta la arquitectura del servicio (ETL, Lambda, FastAPI, hexagonal, etc.).
- Entry points/routers permanecen delgados; la lógica de negocio no quedó en handlers.
- La interfaz HTTP/evento sigue el contrato aprobado y sus errores están definidos.

### Logging, configuración y seguridad
- Logging estructurado con `trace_id` o helper equivalente.
- No hay secretos hardcodeados ni configuración sensible incrustada en código.
- Si cambió runtime/dependencias/env vars, también se actualizaron `pyproject.toml`, `template.yaml` o manifests relevantes.

### Persistencia, tipado y calidad
- SQL o acceso a datos usa mecanismos seguros; no concatena input.
- Type hints, validación y formateo siguen el estándar del repo.
- No hay side-effects globales, código muerto ni helpers temporales abandonados.

### Testing
- Existen tests `pytest` para happy path y errores relevantes.
- Cobertura/checks del repo fueron ejecutados o se reporta explícitamente por qué no.
- Fixtures/datos de prueba son mantenibles y no frágiles.

## Done Criteria

Un review está completo cuando:
- el cambio fue contrastado contra contrato/specs y reglas canónicas;
- los hallazgos tienen archivo/línea/severidad suficientes para actuar;
- quedó claro qué falta para aprobar o por qué puede aprobarse.
