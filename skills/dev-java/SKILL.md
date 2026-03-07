---
name: dev-java
description: >
  Implementa cambios en servicios Java (Spring Boot WebFlux/R2DBC) siguiendo el estándar canónico de SmartPay/ASULADO.
  Trigger: Cuando el usuario pida implementar/fix/refactor o agregar endpoints/tests en un servicio Java.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.2"
  scope: [root]
  auto_invoke:
    - "Implementar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Este skill es la **fuente canónica** para implementación Java en el kit. Las reglas aquí definen cómo debe escribir código la IA para servicios Spring Boot WebFlux + R2DBC dentro de SmartPay/ASULADO.

## Source of truth (precedencia)

1. `AGENTS.md` del repo y contexto local del servicio.
2. Skills overlay del micro (`./skills/*`) cuando apliquen.
3. Artefactos funcionales aprobados: `openspec/changes/<change>/...` o `context/hu/<HU_ID>/...`.
4. Este skill.

Si el repo tiene una regla más estricta, gana el repo.

## Required Context (load order)

1. Leer `AGENTS.md` y `context/` relevante del repo.
2. Si existe `openspec/changes/<change-name>/`, leer `proposal.md`, specs, `design.md` y `tasks.md`.
3. Si no existe `openspec/`, leer la HU y sus artefactos (`contrato.md`, `plan-implementacion.md`).
4. Cargar skills locales relevantes (error codes, SQL providers, etc.).
5. Revisar código y tests similares en el módulo/capa afectada antes de escribir código nuevo.

## Mandatory Gate

No implementes cambios no triviales sin uno de estos dos insumos:

- **SDD activo**: `proposal/spec/design/tasks` suficientemente definidos en `openspec/changes/<change-name>/`.
- **HU tradicional**: contrato + plan de implementación aprobados en `context/hu/<HU_ID>/`.

Si faltan esos artefactos:
- usar `smartpay-sdd-orchestrator` si el usuario quiere flujo SDD completo, o
- usar `planning-java` si el cambio se está trabajando por HU/contrato.

## Implementation Workflow

1. Confirmar alcance, criterios de aceptación y capa(s) afectadas.
2. Implementar por lotes pequeños siguiendo `tasks.md` o el plan de la HU.
3. Actualizar tests en paralelo al código (no dejar testing para el final).
4. Verificar contrato, error codes, logs, constantes y cleanup antes de cerrar.
5. Ejecutar pruebas reales (`./gradlew test` o el comando equivalente del repo) y reportar evidencia.

## Reglas Java no negociables

### 1) Arquitectura y capas
- Mantener arquitectura hexagonal/clean: **Domain → UseCase → Infrastructure → Entry Points**.
- El dominio no depende de Spring ni de infraestructura.
- Los UseCases orquestan puertos; no deben depender de DTOs de API ni de adapters concretos.
- Los adapters implementan puertos y hacen mapeos; no contienen reglas de negocio.
- Routers/handlers validan/adaptan entrada/salida; no resuelven negocio.

### 2) Naming y estructura
- Código en inglés; logs, mensajes y Swagger en español.
- Puertos del dominio con sufijo `Port` o `Gateway`; evita `*Repository` para puertos.
- En HU nuevas evita nombres genéricos como `execute`, `Get*` o `Query*`; el nombre del UseCase debe reflejar intención.
- Para adapters evita nombres mezclados tipo `RepositoryAdapter`; usa nombres concretos como `ParticipantAdapter`.
- Evita FQCN inline dentro del código; importa al inicio.

### 3) Reactividad (Reactor/WebFlux)
- Prohibido `.block()`, `Thread.sleep`, JDBC, I/O bloqueante o `subscribe()` manual en lógica de negocio.
- No anidar suscripciones ni meter side-effects en `map`.
- Evita `collectList()` + `Flux::fromIterable` cuando el objetivo es seguir procesando; prefiere streaming con `concatMap`/`flatMap` controlado.
- En lotes, maneja errores por elemento cuando el caso lo requiera; un fallo puntual no debe abortar todo el proceso sin justificación.

### 4) Persistencia, queries y SQL
- Si la consulta es simple, prefiere derived query en `ReactiveCrudRepository`/`CrudRepository`.
- Si es intermedia y legible, `@Query` es aceptable.
- Si es compleja, usa `DatabaseClient`/`SQLProvider`.
- SQL siempre con parámetros nombrados; nunca concatenes input del usuario.
- En SQL Providers usa una query base clara y agrega filtros opcionales con `append` controlado.
- Usa alias explícitos y legibles en `SELECT`; para columnas derivadas/mapeadas prefiere alias en `snake_case`.
- No disperses strings técnicos repetidos (bind names, columnas, headers, estados, claves); centralízalos en constantes cuando se reutilicen.

### 5) Mappers, modelos y validación
- MapStruct/mappers solo mapean; no llevan lógica de negocio.
- En adapters R2DBC, el mapeo `row -> modelo` debe delegarse en `*RowMapper` cuando el repo siga ese patrón.
- Los modelos de dominio no deben usar sufijo `Row`; los modelos de lectura/mapeo viven en infraestructura.
- Validaciones de entrada en DTOs con Bean Validation + `ValidatorEngine`/traducciones del repo.
- Evita validaciones manuales en handlers/usecases salvo reglas puramente de negocio.

### 6) Contrato API, errores, logs y constantes
- Mantén alineados router/handler/OpenAPI/DTO/tests con el contrato aprobado.
- Toda respuesta esperada debe tener código y ejemplo JSON en el contrato/HU o en el spec activo.
- Los errores funcionales deben modelarse con `BusinessException` + `ErrorCode` del micro.
- Los logs van en español, sin PII, con `traceId` como primer dato de correlación.
- No concatenes strings con `+` en logs; usa placeholders.
- Literales repetidos o de negocio deben vivir en `Constants` o clases equivalentes.

### 7) Testing obligatorio
- Por HU o task relevante, cubrir como mínimo: UseCase + SQL Provider + Adapter + Handler/Router (según aplique).
- En unit tests, SUT con `@InjectMocks` y dependencias con `@Mock`; evita `@Spy` salvo necesidad técnica real.
- Centraliza datos en `*TestData`/Object Mother del módulo; no hardcodees estados ni valores de negocio inline.
- Para Reactor usa `StepVerifier`; para API reactiva usa `WebTestClient` si el repo lo usa.
- En tests de SQL valida cláusulas críticas y mapa de parámetros, no el SQL completo literal.

### 8) Cleanup y calidad
- Elimina código muerto, DTOs/mappers/rutas/tests/constantes sin uso después del refactor.
- No dejes código comentado ni `@SuppressWarnings` sin justificación técnica acotada.
- Evita duplicación, magic numbers, métodos gigantes y imports wildcard.

## Done Criteria

Antes de cerrar el cambio confirma:
- contrato/specs siguen alineados con la implementación;
- tests relevantes pasan con evidencia real;
- no quedan strings técnicos regados, código muerto ni atajos reactivos incorrectos;
- reportas archivos tocados, pruebas ejecutadas y cualquier desviación del plan.

## Optional References

- `.ai-kit/references/java-api-examples.md`
- `.ai-kit/references/contract-template-java.md`
- `.ai-kit/references/plan-template-java.md`
- `.ai-kit/references/sdd/sdd-playbook.md`
