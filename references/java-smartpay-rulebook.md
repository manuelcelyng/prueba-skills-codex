# Java SmartPay Rulebook

Rulebook canónico para micros Java de SmartPay/ASULADO. Úsalo como fuente de verdad de reglas técnicas durante `planning-java`, `dev-java` y `review`.

## Cómo leer este documento
- **ID**: identificador estable de la regla.
- **Rule**: mandato concreto.
- **Apply in**: dónde debe reflejarse (`planning`, `dev`, `review`).
- **Avoid / Prefer**: ejemplos cortos para reducir ambigüedad.

## Mapa rápido de reglas

| Group | IDs | Tema |
|---|---|---|
| Arquitectura | `J-ARC-001` a `J-ARC-006` | Hexagonal, ownership de capas, puertos |
| Naming | `J-NAM-001` a `J-NAM-007` | Idioma, nombres de UseCase, puertos, clases y utilitarios |
| Reactividad | `J-REA-001` a `J-REA-006` | WebFlux/R2DBC, sin bloqueos, composición |
| Contrato / auditoría / validación | `J-API-001` a `J-API-006` | Responses auditadas, validaciones, traceId |
| Mapeo | `J-MAP-001` a `J-MAP-005` | MapStruct, mapping entre capas, builders inline |
| Persistencia y SQL | `J-SQL-001` a `J-SQL-006` | Strategy, named params, aliases, row mapping |
| Errores y logging | `J-ERR-001` a `J-ERR-004` | `BusinessException`, `ErrorCode`, logs, constantes |
| Testing | `J-TST-001` a `J-TST-008` | TDD, naming, `*TestData`, slices mínimas |
| Calidad | `J-QLT-001` a `J-QLT-007` | Clean code, smells, comentarios, wrappers y configuración muerta |
| Documentación | `J-DOC-001` a `J-DOC-003` | contrato, ADRs, catálogos |

---

## Arquitectura

### J-ARC-001 — Hexagonal/Clean obligatoria
- **Rule**: mantener la dirección `Domain → UseCase → Infrastructure → Entry Points`.
- **Apply in**: planning, dev, review.
- **Why**: separa negocio, transporte y detalles técnicos.

### J-ARC-002 — Los puertos externos del dominio usan siempre sufijo `Port`
- **Rule**: si el dominio expone una dependencia o contrato externo, el nombre termina en `Port`.
- **Apply in**: planning, dev, review.
- **Avoid**: `CalendarGateway`, `AuditGateway`, `ParticipantRepository`.
- **Prefer**: `CalendarPort`, `AuditPort`, `ParticipantPort`.

### J-ARC-003 — UseCase orquesta; adapters y entry points no hacen negocio
- **Rule**: la lógica de negocio vive en dominio/usecase; adapters, mappers, routers y handlers solo adaptan, validan, persisten o transportan.
- **Apply in**: planning, dev, review.

### J-ARC-004 — Entry points gestionan boundary concerns
- **Rule**: routers/handlers leen `traceId`, validan input, llaman al UseCase y construyen la respuesta estándar.
- **Apply in**: planning, dev, review.

### J-ARC-005 — Dependencias técnicas siempre por inyección, nunca por instancia manual
- **Rule**: handlers, usecases, adapters y servicios no deben instanciar colaboradores técnicos (`new`, `INSTANCE`, factories estáticas) cuando el framework o el módulo ya los expone como dependencia inyectable.
- **Apply in**: planning, dev, review.
- **Avoid**: `Mapper.INSTANCE`, `new ResponseBuilderService()`, `new AuditService()` dentro del flujo.
- **Prefer**: inyección por constructor de mappers, builders, publishers y servicios.

### J-ARC-006 — En `novedades`, el baseline de `reactive-web` replica a los micros de referencia
- **Rule**: piezas transversales de `reactive-web` (router base/path style, CORS, security headers, filters y convenciones de entry point) deben alinearse con `recepcion`, `liquidacion` y `dispersion`, salvo desviación aprobada y documentada.
- **Apply in**: planning, dev, review.

---

## Naming

### J-NAM-001 — Código en inglés; superficie externa en español
- **Rule**: clases, métodos, variables y paquetes en inglés. Logs, mensajes, Swagger/OpenAPI y responses en español.
- **Apply in**: planning, dev, review.

### J-NAM-002 — El nombre del UseCase se ancla al modelo/capacidad, no al flujo puntual
- **Rule**: el nombre de la clase `UseCase` debe describir el modelo o capacidad principal del negocio y evitar verbos genéricos o sufijos de flujo/operación que no agreguen semántica real.
- **Apply in**: planning, dev, review.
- **Avoid**: `ManageDeductionUseCase`, `DeductionRegistrationUseCase`, `CreateNoveltyUseCase`, `ProcessLiquidationUseCase`, `ExecuteDeductionUseCase`.
- **Prefer**: `DeductionUseCase`, `ChangesMessageUseCase`, `LiquidationBatchUseCase`, `AuditTraceabilityUseCase`.

### J-NAM-003 — Métodos públicos de UseCase con nombre semántico, nunca `execute`
- **Rule**: el método público del UseCase debe expresar el resultado o interacción de negocio; `execute`, `process`, `manage`, `handle` no son aceptables como nombre genérico.
- **Apply in**: planning, dev, review.
- **Avoid**: `execute()`, `manage()`, `process()`.
- **Prefer**: `registerDeduction()`, `publishAuditMessage()`, `loadRetainedPayments()`.

### J-NAM-004 — Naming estándar de clases auxiliares y tests
- **Rule**: usar sufijos consistentes (`Adapter`, `Mapper`, `Router`, `Handler`, `SQLProvider`, `TestData`, `*Test`).
- **Apply in**: planning, dev, review.

### J-NAM-005 — Clases utilitarias y `*TestData` se declaran con `@UtilityClass`
- **Rule**: toda clase utilitaria sin estado compartido (incluyendo `*TestData`, helpers estáticos y clases de constantes derivadas del patrón del repo) debe declararse con `lombok.experimental.UtilityClass`.
- **Apply in**: planning, dev, review.
- **Avoid**: clases helper con constructor implícito/privado manual, `new TestData()`, utilitarios instanciables.
- **Prefer**: `@UtilityClass public class DeductionTestData { ... }`.

### J-NAM-006 — Los `Port` se nombran por entidad/capacidad, no por acción verbal
- **Rule**: además de terminar en `Port`, el nombre del puerto debe representar la entidad o capacidad del dominio y evitar verbos o procesos.
- **Apply in**: planning, dev, review.
- **Avoid**: `DeductionRegistrationPort`, `NoveltyPublishPort`, `CalendarQueryPort`.
- **Prefer**: `DeductionPort`, `ChangesMessagePort`, `CalendarPort`.

### J-NAM-007 — Abstracciones reutilizables se nombran por capacidad genérica
- **Rule**: si una abstracción técnica puede reutilizarse más allá de una HU o agregado puntual (por ejemplo mensajería, auditoría o publicación de cambios), su nombre debe reflejar esa capacidad genérica y no un contexto transitorio.
- **Apply in**: planning, dev, review.
- **Avoid**: `NoveltyMessagePort`, `SqsNoveltyMessagePublisherAdapter`, `DeductionRegistrationPublisher`.
- **Prefer**: `ChangesMessagePort`, `SqsChangesMessagePublisherAdapter`, `ChangesPublisher`.

---

## Reactividad

### J-REA-001 — Flujos HTTP y de negocio reactivos end-to-end
- **Rule**: en entry points, usecases y adapters del flujo principal usar Mono/Flux de extremo a extremo.
- **Apply in**: planning, dev, review.

### J-REA-002 — Prohibido bloquear
- **Rule**: no usar `.block()`, `Thread.sleep`, JDBC ni I/O bloqueante dentro del flujo reactivo principal.
- **Apply in**: dev, review.

### J-REA-003 — `subscribe()` manual solo en bordes técnicos justificados
- **Rule**: un `subscribe()` manual solo es aceptable en servicios de borde claramente aislados (fire-and-forget audit/messaging) y debe quedar encapsulado, justificado y protegido contra errores.
- **Apply in**: planning, dev, review.

### J-REA-004 — No materializar para reemitir sin justificación
- **Rule**: evitar `collectList()` + `Flux::fromIterable` cuando el objetivo es seguir procesando; preferir composición streaming.
- **Apply in**: dev, review.

### J-REA-005 — La respuesta principal no se delega a publicación asíncrona
- **Rule**: la respuesta HTTP del caso principal se construye y retorna dentro del flujo principal exitoso; publicaciones asíncronas (auditoría, SQS, fire-and-forget) quedan aisladas como side effect técnico y no definen el resultado base del endpoint.
- **Apply in**: planning, dev, review.

### J-REA-006 — Las excepciones técnicas deben mapearse dentro del flujo reactivo
- **Rule**: si una operación síncrona previa al `Mono`/`Flux` puede fallar (serialización JSON, object mappers, parsing, builders técnicos), no encapsularla en `try/catch` que lance la excepción fuera del pipeline. Debe envolverse con `Mono.fromCallable`, `Mono.defer` o equivalente y mapearse con `onErrorMap` / `onErrorResume` dentro del flujo.
- **Apply in**: dev, review.
- **Avoid**: `try/catch` alrededor de `objectMapper.writeValueAsString(...)` que termina en `throw new BusinessException(...)` antes de retornar el `Mono`.
- **Prefer**: `Mono.fromCallable(() -> objectMapper.writeValueAsString(dto)) .onErrorMap(JsonProcessingException.class, ...) .flatMap(publisher::send)`.

---

## Contrato, auditoría y validación

### J-API-001 — Toda respuesta pasa por builders/utilitarios auditables
- **Rule**: responses exitosas y de error deben construirse vía builders o servicios centralizados que garanticen trazabilidad/auditoría.
- **Apply in**: planning, dev, review.

### J-API-002 — `traceId` obligatorio en responses y observabilidad
- **Rule**: toda respuesta estándar expone `idTrazabilidad`/`traceId`; handlers y filtros deben leer o generar el trace cuando falte.
- **Apply in**: planning, dev, review.

### J-API-003 — Validaciones con mensajes en español y campo traducido
- **Rule**: los errores de validación deben responder en español e indicar el campo funcional (`campo`, `mensaje`), no solo el path técnico Java.
- **Apply in**: planning, dev, review.

### J-API-004 — Validación en DTO/boundary con Bean Validation + validator centralizado
- **Rule**: usar anotaciones de validación y/o `ValidatorEngine` del repo; evitar validaciones manuales dispersas en handlers o usecases salvo reglas de negocio.
- **Apply in**: planning, dev, review.

### J-API-005 — Contrato y OpenAPI alineados con el payload real
- **Rule**: request, response, ejemplos JSON, códigos HTTP y `ErrorCode` deben estar alineados entre contrato, OpenAPI, handlers y tests.
- **Apply in**: planning, dev, review.

### J-API-006 — Paths y shape del entry point se sincronizan con el baseline del workspace
- **Rule**: cuando el review funcional marque un path o shape de router para `novedades`, ese ajuste debe reflejarse también en tests, curls, contrato y artefactos HU/SDD del micro.
- **Apply in**: planning, dev, review.

---

## Mapeo

### J-MAP-001 — MapStruct es el estándar para mapping entre capas
- **Rule**: todo mapping DTO↔domain, domain↔entity, DTO↔message o entity↔domain debe vivir en mappers MapStruct salvo excepción muy justificada.
- **Apply in**: planning, dev, review.

### J-MAP-002 — No hardcodear creación de objetos cross-layer en flujos
- **Rule**: handlers, usecases y adapters no deben construir manualmente objetos de otra capa cuando el cambio sea claramente un mapping; usar mapper o método dedicado.
- **Apply in**: dev, review.
- **Avoid**: builder chains inline para pasar DTO→dominio o dominio→DTO dentro del flujo.
- **Prefer**: `DeductionRegistrationRequestMapper`, `DeductionRegisterResponseMapper`, `AuditMapper`.

### J-MAP-003 — Normalizaciones repetibles viven en mapper/helper dedicado
- **Rule**: trims, uppercase y normalizaciones sistemáticas deben quedar en `@AfterMapping`, mapper helper o método privado dedicado; no regadas por todo el flujo.
- **Apply in**: dev, review.

### J-MAP-004 — Mappers sin lógica de negocio
- **Rule**: un mapper transforma estructura/formato; no decide reglas de negocio.
- **Apply in**: planning, dev, review.

### J-MAP-005 — Mappers de infraestructura gestionados por Spring
- **Rule**: los mappers MapStruct consumidos por adapters, handlers o servicios deben declararse con `@Mapper(componentModel = "spring")` e inyectarse; en código productivo no se usa `INSTANCE`/`Mappers.getMapper(...)`.
- **Apply in**: planning, dev, review.
- **Avoid**: `ChangesRequestEntityMapper.INSTANCE.toEntity(...)`.
- **Prefer**: `private final ChangesRequestEntityMapper changesRequestEntityMapper`.

---

## Persistencia y SQL

### J-SQL-001 — Strategy de query según complejidad
- **Rule**: derived query para lo simple, `@Query` para lo intermedio legible, `DatabaseClient`/`SQLProvider` para lo complejo.
- **Apply in**: planning, dev, review.

### J-SQL-002 — SQL siempre parametrizado
- **Rule**: usar named params/bind; nunca concatenar input del usuario.
- **Apply in**: planning, dev, review.

### J-SQL-003 — SQL Providers legibles y cohesionados
- **Rule**: query base clara, filtros opcionales encapsulados, métodos cohesionados y sin mezclar demasiadas responsabilidades.
- **Apply in**: planning, dev, review.

### J-SQL-004 — Alias explícitos y semánticos
- **Rule**: los alias de columnas/derivados deben ser legibles; usar `snake_case` solo en aliases SQL cuando mejore el mapping.
- **Apply in**: dev, review.

### J-SQL-005 — Row mapping separado de la lógica del adapter
- **Rule**: cuando el repo siga patrón `*RowMapper`, usarlo; el adapter no debe mezclar SQL, mapping complejo y negocio en un solo método.
- **Apply in**: planning, dev, review.

### J-SQL-006 — Repositorios R2DBC simples se mantienen delgados
- **Rule**: para persistencia reactiva simple usar `R2dbcRepository` y métodos derivados explícitos; no agregar `ReactiveQueryByExampleExecutor`, helpers genéricos o extensiones de repositorio si el flujo no las necesita.
- **Apply in**: planning, dev, review.
- **Avoid**: repositorios que extienden varios contratos reactivos genéricos “por si acaso”.
- **Prefer**: `public interface DeductionRepository extends R2dbcRepository<...>`.

---

## Errores, logging y constantes

### J-ERR-001 — Error funcional siempre como `BusinessException` + `ErrorCode`
- **Rule**: no propagar `RuntimeException` cruda hacia entry points; mapear las excepciones técnicas al catálogo del micro.
- **Apply in**: planning, dev, review.

### J-ERR-002 — Logs en español, sin PII, con `traceId`
- **Rule**: logs funcionales en español, sin datos sensibles, e incluyendo `traceId` como dato principal de correlación.
- **Apply in**: dev, review.

### J-ERR-003 — Literales repetidos a `Constants`
- **Rule**: headers, logs, columnas, estados, mensajes y códigos repetidos deben salir de `Constants` o clases equivalentes.
- **Apply in**: planning, dev, review.

### J-ERR-004 — No concatenar logs con `+`
- **Rule**: usar placeholders del logger; no armar mensajes manualmente.
- **Apply in**: dev, review.

---

## Testing

### J-TST-001 — Flujo base TDD
- **Rule**: analizar HU/change, diseñar pruebas primero, implementar por capas, refactorizar y luego validar build/tests.
- **Apply in**: planning, dev, review.

### J-TST-002 — Cobertura mínima por slice
- **Rule**: cada cambio relevante debe cubrir al menos UseCase + SQLProvider + Adapter + Handler/Router, según aplique.
- **Apply in**: planning, dev, review.

### J-TST-003 — Naming de tests
- **Rule**: clase `XxxTest`; método en camelCase inglés, sin `_` ni otros separadores; `@DisplayName` en español, consistente y descriptivo. El patrón `should<Expected>When<Condition>` es el preferido cuando aplique.
- **Apply in**: dev, review.
- **Avoid**: `@DisplayName("shouldMapMetadata_WhenDtoIsValid")`, métodos `snake_case`, nombres en español o estilos mixtos dentro del mismo módulo.
- **Prefer**: método `shouldMapMetadataWhenDtoIsValid()` + `@DisplayName("Debe mapear metadata cuando el DTO es válido")`.

### J-TST-004 — Datos de prueba centralizados
- **Rule**: usar `*TestData`, fixtures u Object Mothers; evitar datos de negocio hardcodeados regados.
- **Apply in**: dev, review.

### J-TST-005 — Reactor y asserts correctos
- **Rule**: `StepVerifier` para flujos reactivos, `WebTestClient` para entry points reactivos, AssertJ encadenado cuando aplique.
- **Apply in**: dev, review.

### J-TST-006 — Wiring Mockito estándar
- **Rule**: en unit tests usar `@InjectMocks` para el SUT y `@Mock` para dependencias; nombres de variables de prueba deben ser descriptivos y evitar abreviaturas crípticas.
- **Apply in**: dev, review.

### J-TST-007 — Datos repetidos a `*TestData` y matrices a tests parametrizados
- **Rule**: valores repetidos, payloads y expectativas reutilizables viven en `*TestData`; si un test cubre una matriz de casos homogéneos, preferir test parametrizado en vez de duplicación.
- **Apply in**: dev, review.

### J-TST-008 — No testear config simple ni mappers aislados sin valor funcional
- **Rule**: clases `@Configuration`, beans simples, helpers sin comportamiento y mappers de infraestructura no se testean de forma aislada cuando su valor ya queda cubierto por adapters, usecases o entry points.
- **Apply in**: dev, review.

---

## Calidad

### J-QLT-001 — Sin code smells evidentes
- **Rule**: evitar métodos gigantes, parámetros >5 sin objeto, duplicación, nested logic innecesaria, imports wildcard y mutabilidad compartida en flujos.
- **Apply in**: planning, dev, review.

### J-QLT-002 — Sin código comentado ni comentarios explicativos innecesarios
- **Rule**: no dejar código comentado ni comentarios de relleno (`Given/When/Then`, explicación obvia, TODOs genéricos). La claridad debe salir del naming y la extracción de métodos.
- **Apply in**: dev, review.

### J-QLT-003 — Sin hardcode repetido ni magic numbers
- **Rule**: si un literal/número se repite o tiene significado de negocio, extraerlo.
- **Apply in**: dev, review.

### J-QLT-004 — Código limpio antes que parches inline
- **Rule**: si una construcción compleja cabe mejor en un mapper, helper o value object, extraerla; no dejar builder chains opacos en el flujo principal.
- **Apply in**: dev, review.

### J-QLT-005 — La intención se expresa con estructura, no con comentarios
- **Rule**: preferir nombres semánticos, métodos cortos y helpers dedicados en vez de explicar código con comentarios.
- **Apply in**: dev, review.

### J-QLT-006 — No introducir wrappers/value objects artificiales sin comportamiento
- **Rule**: evita crear objetos intermedios o wrappers de dominio que solo agrupen campos del contrato si no agregan invariantes, comportamiento o semántica real.
- **Apply in**: planning, dev, review.
- **Avoid**: encapsular dos strings (`periodicity`, `frequency`) en un objeto extra sin reglas propias.
- **Prefer**: aplanar los campos o crear un value object solo si valida, protege invariantes o aporta operaciones de dominio claras.

### J-QLT-007 — No agregar beans, `@Configuration` o helpers sin consumidor real
- **Rule**: no introducir configuración, beans auxiliares o clases helper si el framework ya resuelve la dependencia o si no existe un uso real y verificable en el código.
- **Apply in**: planning, dev, review.
- **Avoid**: `ObjectMapperConfig`/helpers que solo envuelven una implementación default sin un consumidor explícito.
- **Prefer**: apoyarse en autoconfiguración existente o agregar el bean solo cuando haya una necesidad real demostrable por el código y las pruebas.

---

## Documentación y mantenimiento

### J-DOC-001 — Si cambias contrato o errores, actualiza artefactos
- **Rule**: cambios en response codes, payloads o errores deben reflejarse en contrato/HU/specs y catálogos del micro.
- **Apply in**: planning, dev, review.

### J-DOC-002 — ADR para decisiones estratégicas
- **Rule**: dependencias nuevas o decisiones de arquitectura con trade-offs deben dejar rastro documental.
- **Apply in**: planning, review.

### J-DOC-003 — Planning debe cubrir todas las familias de reglas
- **Rule**: el contrato y plan deben anticipar arquitectura, naming, validación, auditoría, mapping, SQL, errores, tests y cleanup.
- **Apply in**: planning, review.
