# Guía HU (SDD) + prompts (AI Kit)

Esta guía consolida el uso de HUs con IA (SDD) para repos Java/Python del workspace.

Objetivo: que la IA use **contrato → plan → implementación → review** y no “salte” directo a código.

## Source of truth

1) `AGENTS.md` del repo (reglas locales).
2) Reglas comunes del kit:
   - `.ai-kit/references/java-rules.md`
   - `.ai-kit/references/python-rules.md`
3) Contexto del repo si existe: `context/` (HUs, ADRs, error-codes, etc.).

## Plantilla HU

Usa la plantilla base:
- `.ai-kit/references/hu-context-template.md`

Convención recomendada:
- `context/hu/<HU_ID>/contrato.md`
- `context/hu/<HU_ID>/plan-implementacion.md`

## Flujo SDD recomendado

1) **Cargar contexto**: `AGENTS.md` + `context/` relevante.
2) **Contrato**:
   - Ruta/método, headers (traceId), request/response.
   - Códigos de respuesta + ejemplos JSON (incluye errores).
   - Validaciones (Bean Validation / reglas adicionales).
3) **Plan de implementación**:
   - Cambios por capa (dominio/usecase/infra/entry points).
   - SQL borrador con named params (si aplica).
   - Plan de pruebas por capa.
4) **Implementar** (TDD si aplica).
5) **Review** (checklists de arquitectura, reactividad, SQL parametrizado, tests).

## Prompts recomendados (copiar/pegar)

### 0) Arranque (router)
“Actúa como par programador senior. Lee y respeta `AGENTS.md` y las reglas del repo. Si falta contrato o plan, detente y pídelo o propón uno.”

### 1) Contrato (planning)
“Redacta el contrato para HU `<HU_ID>`: endpoint, request/response con ejemplos JSON, validaciones, códigos de error y mapeo a `ErrorCode`. Mensajes en español; nombres internos en inglés.”

### 2) Plan (planning)
“Crea el plan de implementación para HU `<HU_ID>`: cambios por capa, borrador SQL con named params (si aplica), constantes/logs, mapeo de errores, y plan de pruebas por UseCase/SQLProvider/Adapter/Handler.”

### 3) Implementación (dev)
“Implementa la HU `<HU_ID>` siguiendo el plan. Mantén arquitectura hexagonal y reactividad end-to-end (sin `.block()`). SQL parametrizado. Agrega/actualiza tests por capa.”

### 4) Cierre (review)
“Revisa cumplimiento: contrato+plan, error-codes actualizado si aplica, sin hardcode strings, sin bloqueos, SQL parametrizado, logs en español con traceId, y tests por capa.”

