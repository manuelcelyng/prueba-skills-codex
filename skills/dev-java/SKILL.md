---
name: dev-java
description: Implementa cambios en servicios Java (Spring Boot WebFlux/R2DBC). Usar para desarrollo, fixes, refactors o pruebas Java; seguir AGENTS.md y context/ del repo.
metadata:
  scope: root
  auto_invoke:
    - "Implementar cambios"
---

# Desarrollo Java

Usa este skill para implementar cambios en servicios Java del repo actual.

## Carga de contexto obligatoria (antes de escribir codigo)
1. Leer `AGENTS.md`.
2. Leer `.ai-kit/references/context-readme.md`.
3. Leer `.ai-kit/references/java-rules.md`.
4. Si existe `context/agent-master-context.md`, leerlo completo.
5. Si hay HU, leer `context/hu/<HU_ID>/` y todos los contratos/planes existentes.
6. Si existen, leer: `context/adr_optimized.md`, `context/dependencies_optimized.md`, `context/error-codes.md`, `context/ejemplos-api_optimized.md`, `context/mejores-practicas-calidad-codigo.md`.
7. Si se crea HU/contrato, leer `context/ai/hu-prompts-and-template-usage.md` y el template si existe (`context/hu/_template/hu-context-template.md`).

## Inventario de contextos Java (para ubicar reglas)
- `context/agent-master-context.md` (si existe)
- `context/ai/hu-prompts-and-template-usage.md` (si existe)
- `context/hu/` (HUs y `_template/`)
- `context/adr_optimized.md`, `context/dependencies_optimized.md`, `context/error-codes.md`, `context/ejemplos-api_optimized.md`, `context/mejores-practicas-calidad-codigo.md` (si existen)

## Gate obligatorio de planificacion
Verificar que existan:
- Contrato API con codigos de respuesta y ejemplos JSON para todas las respuestas.
- Plan de implementacion con SQL borrador (named params) y cambios por capa.
Si falta alguno, solicitar primero `planning-java` y detener implementacion.

## Reglas criticas (resumen)
- Arquitectura hexagonal/clean: dominio -> usecase -> infraestructura -> entry points.
- Puertos (gateways): sufijo `Port` (evitar `*Repository` para puertos/gateways).
- WebFlux + R2DBC end-to-end; prohibido bloquear (`.block()`, `Thread.sleep`, JDBC).
- Codigo en ingles; logs, mensajes y Swagger en espaniol.
- Regla de refactor: todo componente desacoplado por el cambio (clases, DTOs, mappers, rutas, tests y constantes sin uso) debe eliminarse en la misma tarea; no dejar codigo muerto o basura.
- Literales en `Constants` (logs, headers, columnas, estados); sin hardcode.
- Regla obligatoria de strings: cualquier literal tecnico/funcional (incluyendo nombres de parametros SQL bind como `batchId`, claves de mapa, textos de log y nombres de columnas) debe extraerse a constantes del dominio/modulo; en adapters no dejar strings inline.
- Regla obligatoria de integraciones entre servicios: todo endpoint consumido por el servicio hacia otro microservicio debe configurarse por propiedades (`application-*.yml` y `deployment/k8s/configsecret.yaml`), evitando paths hardcodeados en adapters/configs.
- Evitar `@SuppressWarnings` en código productivo; solo permitirlo con justificación técnica explícita (limitación de framework/librería) y alcance mínimo.
- Errores como `BusinessException` con `ErrorCode` del modulo; no propagar `RuntimeException`.
- SQL Providers con parametros nombrados; nunca concatenar input.
- En SQL de adapters (especialmente HU nuevas/refactor), declarar alias explicitos y legibles directamente en el `SELECT` (ej. `AS liquidation_batch_id`), evitando construir alias por `String.format` o placeholders que reduzcan legibilidad.
- Regla de alias SQL: todo alias de columna debe seguir `snake_case` (minusculas y guion bajo), incluyendo campos de conteo/fechas/ids usados por mappers.
- MapStruct para mapeos; sin logica de negocio en mappers, adapters o routers.
- Regla de mapeo: cualquier transformacion entre modelos (infra <-> dominio) y armado de respuestas debe vivir en `*Mapper`/`*ResultMapper`; los UseCase solo orquestan el flujo reactivo.
- Regla R2DBC: la construccion/mapeo de filas consultadas (row -> modelo) debe vivir en `*RowMapper`; no construir respuestas/modelos directamente dentro de adapters.
- Modelos: los modelos usados para mapeos/lectura en infraestructura deben vivir en infraestructura (y no terminar en `Row`); los modelos de dominio viven en dominio y no dependen de infraestructura.
- Validaciones de request (UUID, formatos, rangos, tamano de pagina, campos requeridos) deben resolverse en DTOs de entrada con Bean Validation; evitar validaciones manuales en handlers/usecases salvo reglas estrictamente de negocio.
- Validaciones: no crear constantes de paths/mensajes de validacion en `Constants`; usar `ValidatorEngine` + traducciones (`ValidatorEngineConstants`) para devolver campos en español.
- UseCase naming: evitar prefijos `Get*`/`Query*` en clases nuevas; evitar metodos `execute`; preferir nombres descriptivos del caso de uso (sin reflejar verbo REST).
- Adapters naming: evitar nombres que mezclen conceptos (`RepositoryAdapter`); usar `*Adapter` (y solo incluir tecnologia en el nombre si hay multiples implementaciones del mismo `Port`).
- Imports: prohibido usar FQCN inline (ej. `co.com...Class` en el cuerpo); siempre importar y referenciar por nombre simple.
- Respetar reglas especificas del servicio en su `AGENTS.md` (p. ej., en `dispersion` no usar comentarios inline).

## Flujo de implementacion
- Seguir el flujo HU/TDD del `agent-master-context.md`.
- Implementar primero tests de UseCase, SQL Provider, Adapter y Handler/Router.
- Actualizar contratos, `error-codes.md`, ADRs y documentacion HU cuando aplique.

## Pruebas minimas
- UseCase, SQL Provider, Adapter y Handler/Router.
- Usar Reactor Test y `WebTestClient` donde aplique.
- Regla obligatoria de tests HU: no hardcodear strings/valores en el test; crear `*TestData` por test o feature y centralizar ahi constantes/objetos.
- Mockito obligatorio en unit tests: `@ExtendWith(MockitoExtension.class)`, dependencias `@Mock` y SUT con `@InjectMocks`.

## Limites
- No gestionar git, ramas o PRs.

## Referencias
    - `references/context-map-java.md`
    - `references/implementation-checklist-java.md`
