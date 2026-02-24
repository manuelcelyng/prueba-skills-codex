---
name: planning-java
description: Planifica cambios para servicios Java (Spring Boot WebFlux/R2DBC). Usar para scoping/HU/contratos Java; debe generar contrato API con codigos y ejemplos JSON y luego plan de implementacion con SQL antes del desarrollo.
metadata:
  scope: root
  auto_invoke:
    - "Planificar HU / contrato"
---

# Planificacion Java

Usa este skill para planear cambios en servicios Java del repo actual.

## Carga de contexto obligatoria
1. Leer `AGENTS.md`.
2. Leer `.ai-kit/references/context-readme.md`.
3. Leer `.ai-kit/references/java-rules.md`.
4. Si existe `context/agent-master-context.md`, leerlo completo.
5. Si hay HU, leer `context/hu/<HU_ID>/` y el template si existe (`context/hu/_template/hu-context-template.md`).
6. Si existen, leer: `context/adr_optimized.md`, `context/dependencies_optimized.md`, `context/error-codes.md`, `context/ejemplos-api_optimized.md`, `context/mejores-practicas-calidad-codigo.md`.

## Orden de entrega obligatorio
1. Contrato API completo.
2. Plan de implementacion con SQL borrador.
3. Confirmar que el desarrollo puede iniciar con `dev-java`.

## Contrato API (archivo en la HU)
- Guardar en `context/hu/<HU_ID>/contrato.md` o el nombre que ya exista en la HU.
- Definir ruta, metodo, headers y parametros (path/query/body).
- Incluir validaciones de entrada y reglas de negocio relevantes.
- Incluir codigos de respuesta por caso (200/400/404/409/500 o los que apliquen) y mapearlos a `ErrorCode`.
- Incluir JSON de ejemplo para todas las respuestas: exito con datos, exito sin datos y cada error.
- Mantener mensajes en espaniol y nombres internos en ingles.
- Usar la estructura de respuesta del servicio (ver `ejemplos-api_optimized.md` o contratos existentes).
- Actualizar `error-codes.md` si se crean codigos nuevos.

## Plan de implementacion (archivo en la HU)
- Guardar en `context/hu/<HU_ID>/plan-implementacion.md` o el nombre que ya exista en la HU.
- Objetivo, alcance y modulos afectados.
- Fuentes de datos y tablas involucradas.
- SQL base en borrador con named params y filtros esperados.
- Cambios por capa: dominio, usecase, infraestructura, entry points.
- Plan de pruebas por capa (UseCase, SQL Provider, Adapter, Handler/Router).
- Riesgos, dependencias y ADRs requeridos.
- Notas de constantes, logs y validaciones.

## Reglas transversales
- Arquitectura hexagonal/clean y reactividad completa.
- Sin bloqueos (`.block()`, `Thread.sleep`, JDBC).
- Logs y Swagger en espaniol; codigo en ingles.
- Literales en `Constants` y errores con `BusinessException` + `ErrorCode`.
- Regla de planificacion obligatoria: en el diseno tecnico debe quedar explicitado que no se permiten strings hardcodeados en codigo final (incluye adapters y binds SQL como `batchId`); todo string tecnico/funcional debe mapearse a constantes.
- Regla de integracion obligatoria: todo path de endpoint llamado a otro microservicio debe quedar en configuracion (`application-*.yml` y `deployment/k8s/configsecret.yaml`) y documentado como variable para Infra.

## Limites
- No gestionar git, ramas o PRs.

## Referencias
    - `references/contract-template-java.md`
    - `references/plan-template-java.md`
