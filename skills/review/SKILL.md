---
name: review
description: >
  Revisa cambios y valida cumplimiento de reglas, contrato/plan o artefactos SDD, usando dev-java/dev-python como estándar canónico.
  Trigger: Cuando el usuario pida code review, auditoría técnica o validación de HU/checklists.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.7"
  scope: [root]
  auto_invoke:
    - "Revisar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Review (canónico)

Este skill es la **fuente normativa de auditoría** del kit. Su trabajo es validar proceso, cumplimiento técnico y evidencia real contra `dev-java`, `dev-python`, el contrato y los artefactos HU/SDD.

## Shared Operating Model

Leer `references/delivery-flow.md` antes de revisar. Ese documento define precedencia, contexto mínimo, gates y evidencia requerida. `review` no debe aprobar como “listo” un cambio que incumpla ese baseline.

## Normative Baseline

- Para Java, el baseline obligatorio es `dev-java` + `references/java-smartpay-rulebook.md`.
- Para Python, el baseline obligatorio es `dev-python` + `references/python-smartpay-rulebook.md`.
- Usa `references/java-smartpay-reference.md` o `references/python-smartpay-reference.md` solo cuando necesites contrastar contrato, ejemplos, plan, dependencias o ADRs.

## Review Workflow

1. Validar primero el **proceso**: artefactos suficientes, alineación con HU/SDD y cambios documentales requeridos.
2. Revisar después el **cumplimiento técnico** por stack contra el skill canónico de implementación.
3. Verificar por último la **evidencia real**: pruebas, build, cobertura o comandos corridos.
4. Emitir hallazgos ordenados por severidad, con referencias concretas a archivo/línea cuando aplique.

## Output (mandatory)

1. **Hallazgos** primero, ordenados por severidad.
2. Para hallazgos puntuales usar `::code-comment{...}` con archivo y líneas.
3. Luego listar **preguntas / supuestos / faltantes de contexto**.
4. Cerrar con un **resumen corto** del estado general.

## Mandatory Process Checks

Reporta hallazgo de proceso cuando aplique:
- cambio no trivial sin `proposal/spec/design/tasks` ni `contrato + plan`;
- implementación que contradice el contrato o specs aprobados;
- cambio que introduce error codes, dependencias o decisiones sin actualizar la evidencia documental requerida;
- cambio “listo para merge” sin evidencia real de tests/build.

## Java Audit Lens (audit against `dev-java` + rulebook)

### `J-ARC-*` y `J-NAM-*`
- Verifica hexagonal/clean, ownership de capas, puertos `Port` y naming consistente.
- Señala cualquier `Gateway`, `Repository` de dominio, `Port` nombrado por verbo/proceso, abstracción reusable atada a un contexto transitorio (`Novelty`, `Registration`) o `UseCase` nombrado como verbo genérico (`Manage`, `Create`, `Process`, `Handle`, `execute`).
- Señala dominio que no sea la fuente de verdad del negocio, lógica de negocio repartida en DTOs/entities/ViewModels o presencia de modelos de request/response dentro de la capa de Dominio.
- Señala atributos, variables, parámetros o métodos con naming ambiguo/no descriptivo (`x`, `tmp`, `obj`, `data`, etc.) o que no esté alineado al lenguaje ubicuo del dominio.
- Señala helpers, utilitarios o `*TestData` que debían ser `@UtilityClass` y quedaron como clases instanciables.
- Valida que el baseline común de `reactive-web` (router path style, CORS, security headers, filters y convenciones de entry point) siga alineado entre los micros Java del workspace, salvo desviación explícita.

### `J-REA-*`
- Señala `.block()`, `Thread.sleep`, JDBC, `subscribe()` manual no justificado, materialización innecesaria, loops imperativos dentro de código reactivo o composición reactiva defectuosa.
- Señala pipelines fragmentados en exceso cuando varias operaciones del mismo contexto podían leerse de forma fluida dentro del mismo flujo.
- Señala `collectList()`/`Flux.fromIterable()` innecesarios, especialmente si la fuente ya es reactiva o si el volumen esperado pide streaming, límites, paginación o backpressure explícito.
- Señala `try/catch` alrededor de object mappers, serialización JSON o parsing técnico que termina lanzando excepciones antes de retornar el `Mono`/`Flux`; debe pedirse `Mono.fromCallable`/`Mono.defer` + `onErrorMap` dentro del pipeline y, si el error es controlado, mapearlo a `BusinessException`.

### `J-API-*`
- Verifica que success y error responses salgan por builders auditables, que propaguen `traceId`, que el input pase por validator/Bean Validation en el boundary y que las validaciones respondan en español con campo funcional.

### `J-MAP-*` y `J-SQL-*`
- Verifica mappers MapStruct, ausencia de builders cross-layer inline en el flujo, estrategia SQL adecuada, named params, aliases legibles y separación de row mapping.
- Señala uso de `INSTANCE`/`Mappers.getMapper(...)` en código productivo cuando el mapper debía ser Spring-managed.
- Señala repositorios reactivos simples que usen extensiones extra (`ReactiveQueryByExampleExecutor`, helpers genéricos) sin necesidad real en lugar de `R2dbcRepository`.
- `snake_case` solo es aceptable en aliases SQL dentro de providers/queries; fuera de ahí debe reportarse como desviación.

### `J-ERR-*`
- Señala ausencia de `BusinessException` + `ErrorCode`, logs fuera de convención, PII o literales técnicos sin centralizar.

### `J-TST-*` y `J-QLT-*`
- Verifica TDD implícito en el cambio, slices mínimas, métodos de test en camelCase (preferiblemente `shouldXWhenY`), `@DisplayName` en español, `*TestData`, ausencia de code smells, wrappers artificiales, configuración sin consumidor y comentarios innecesarios/código comentado.
- No pidas tests unitarios aislados para mappers estrictamente 1-a-1 si ya quedan cubiertos indirectamente por adapters, usecases o entry points; sí señálalos como faltantes cuando el mapper tenga lógica explícita, transformaciones no triviales, normalizaciones, condiciones o cambios estructurales.
- Si el diff toca `configsecret`, manifests K8s/SAM o configuración operativa, señala `path`, `key`, `url`, endpoints o equivalentes hardcodeados y exige env vars en inglés con naming semántico del dominio/capacidad.
- Señala unit tests sin `@InjectMocks`/`@Mock` cuando el patrón del repo sí aplica.
- Señala tests de config simple, helpers sin comportamiento o mappers de infraestructura aislados cuando debían cubrirse vía adapter/usecase/entry point.
- Cuando haya múltiples casos homogéneos con duplicación, recomienda test parametrizado y extracción de datos a `*TestData`.

### `J-DOC-*`
- Verifica que contrato, catálogo de errores y ADRs/artefactos asociados se hayan actualizado cuando el cambio lo requiere.

## Python Audit Lens (audit against `dev-python` + rulebook)

### `PY-ARC-*`
- Señala handlers/routers/Lambdas con lógica de negocio, ETL o SQL mezclados en el boundary.
- Señala mezcla de capas (`extract` con persistencia, `load` con decisiones de negocio, `transform` con I/O) o falta de lifecycle explícito de recursos (`trace_id`, engines, consumers, lifespan).

### `PY-NAM-*`
- Señala nombres internos en español cuando debían estar en inglés, constantes mal nombradas, identificadores ambiguos/no descriptivos y ausencia de type hints en boundaries/servicios/helpers públicos.
- Señala nombres internos que no respeten `snake_case` / `PascalCase` / `UPPER_SNAKE_CASE`.

### `PY-CON-*`
- Señala contratos/eventos desalineados con el payload real, parseos dispersos de wrappers SQS/EventBridge y falta de normalización centralizada de metadata.
- Señala IDs o campos requeridos que no se validan/sanitizan al inicio del flujo.
- Señala metadata inventada o hardcodeada en vez de preservarse desde el evento.

### `PY-OBS-*`
- Señala ausencia de `trace_id`, lifecycle incompleto, logs sin contexto o errores ambiguos.
- Señala logging de payloads crudos, PII, secretos o DataFrames completos.

### `PY-CFG-*` y `PY-RUN-*`
- Señala secretos hardcodeados, `path`/`key`/`url`/queue names/endpoint hardcodeados o metadata operativa fija (`usuario`, `usuarioIp`, etc.).
- Señala cambios de runtime, env vars, SAM/K8s, `Dockerfile`, `pyproject.toml`, `samconfig*` o lifecycle FastAPI que no fueron acompañados por sus artefactos operativos.

### `PY-MAP-*` y `PY-SQL-*`
- Señala mappers/transformers con side effects, sin validación de inputs o con lógica de I/O.
- Señala acceso a datos fuera de `extract/load/repositories`, concatenación insegura de SQL, batch/upsert improvisado o lifecycle deficiente de engine/conexiones.

### `PY-TST-*` y `PY-QLT-*`
- Verifica `pytest` suficiente para happy path + error path, estructura de tests coherente con capas y cobertura de handler/trace lifecycle cuando el boundary cambia.
- No pidas tests aislados para mappers 1-a-1 si ya están cubiertos indirectamente; sí repórtalos como faltantes cuando haya lookup logic, normalización, dedupe, cálculos o cambios estructurales.
- Señala handlers gigantes, inputs mutados in-place, código muerto, comentarios obsoletos y ausencia de evidencia real de checks.

## Done Criteria

Un review está completo cuando:
- el cambio fue contrastado contra contrato/specs y reglas canónicas del stack;
- los hallazgos tienen archivo, línea y severidad suficientes para actuar;
- quedó claro qué falta para aprobar o por qué puede aprobarse.

## References
- `references/java-smartpay-rulebook.md`
- `references/python-smartpay-rulebook.md`
- `references/java-smartpay-reference.md`
- `references/python-smartpay-reference.md`
