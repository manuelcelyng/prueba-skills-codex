# Python SmartPay Rulebook

Rulebook canónico para servicios Python de SmartPay/ASULADO. Cubre Lambdas ETL y servicios FastAPI/hexagonales, y debe usarse como fuente de verdad durante `planning-python`, `dev-python`, `review` y `gitlab-mr-review-python`.

Este baseline se derivó de patrones reales observados en:
- `lambda-liquidacion-dispersion`
- `lambda-pagos-liquidacion`
- `lambda-recepcion-pagos`
- `motor-reglas-dispersion`
- y de hallazgos de review asociados a los MRs `lambda-liquidacion-dispersion!96` y `lambda-liquidacion-contabilidad!38`

## Cómo leer este documento
- **ID**: identificador estable de la regla.
- **Rule**: mandato concreto.
- **Apply in**: dónde debe reflejarse (`planning`, `dev`, `review`).
- **Avoid / Prefer**: ejemplos cortos para reducir ambigüedad.

## Mapa rápido de reglas

| Group | IDs | Tema |
|---|---|---|
| Arquitectura | `PY-ARC-001` a `PY-ARC-005` | ownership de capas, handlers, ETL y lifecycle |
| Naming y tipado | `PY-NAM-001` a `PY-NAM-004` | idioma, identificadores, constantes y type hints |
| Contrato y validación | `PY-CON-001` a `PY-CON-004` | payloads, metadata, sanitización y responses |
| Observabilidad y errores | `PY-OBS-001` a `PY-OBS-004` | `trace_id`, logging y manejo de errores |
| Configuración y seguridad | `PY-CFG-001` a `PY-CFG-004` | env vars, SSM, metadata operativa y bootstrap |
| Mapping y transformación | `PY-MAP-001` a `PY-MAP-004` | mappers, DataFrames, normalización y pureza |
| Persistencia y SQL | `PY-SQL-001` a `PY-SQL-004` | extract/load/repositories, parámetros y lifecycle |
| Testing | `PY-TST-001` a `PY-TST-005` | `pytest`, estructura, trace lifecycle y mappers |
| Runtime y packaging | `PY-RUN-001` a `PY-RUN-003` | `pyproject.toml`, SAM/FastAPI lifecycle y versión Python |
| Calidad | `PY-QLT-001` a `PY-QLT-004` | cleanup, mutaciones y evidencia real |

---

## Arquitectura

### PY-ARC-001 — El `lambda_handler` o router solo hace boundary/orquestación
- **Rule**: el entry point parsea el evento/request, resuelve `trace_id`, valida mínimos, instancia dependencias del boundary y delega la lógica principal a un servicio/use case.
- **Apply in**: planning, dev, review.
- **Avoid**: handlers con SQL, transformaciones de DataFrame y publicación SQS mezcladas en el mismo bloque principal.
- **Prefer**: `lambda_handler` delgado + `ETLService`, `RequestStatusUpdater`, `UseCase`, `Handler`.

### PY-ARC-002 — Respetar el estilo arquitectónico real del repo
- **Rule**: si el repo es ETL, mantener separación `extract/`, `transform/`, `load/`, `services/`, `validators/`, `utils/`; si es hexagonal/FastAPI, respetar `domain/application/infrastructure/entrypoints`.
- **Apply in**: planning, dev, review.
- **Avoid**: mover lógica de `transform` a `load`, o lógica de negocio a routers/adapters.
- **Prefer**: cada cambio vive en la capa que ya es dueña de esa responsabilidad.

### PY-ARC-003 — La lógica de negocio vive en servicios, use cases o transformaciones del dominio, no en contratos externos
- **Rule**: el negocio se resuelve en servicios/use cases/transformadores del dominio; payloads de eventos, DTOs, responses HTTP y wrappers SQS/EventBridge no deben acumular lógica de negocio.
- **Apply in**: planning, dev, review.
- **Avoid**: decisiones de negocio codificadas en el `event` parser o en el response builder.
- **Prefer**: helpers de boundary para parsear/normalizar, y servicios/use cases para decidir.

### PY-ARC-004 — En ETL, cada etapa tiene ownership explícito
- **Rule**: `extract` lee/consulta, `transform` normaliza/convierte/agrupa, `load` persiste/actualiza y `services`/`usecases` orquestan el flujo.
- **Apply in**: planning, dev, review.
- **Avoid**: `transform` que ejecuta SQL o `load` que decide reglas de agrupación.
- **Prefer**: etapas claras y nombres alineados a la entidad/capacidad (`tpag_*`, `tliq_*`, `tdis_*`).

### PY-ARC-005 — El lifecycle técnico debe quedar explícito y cerrado
- **Rule**: cualquier recurso técnico con lifecycle (`trace_id`, engines, consumers, background tasks, containers) debe inicializarse de forma explícita y liberarse/cerrarse en `finally`, context managers o `lifespan`.
- **Apply in**: planning, dev, review.
- **Avoid**: dejar `trace_id` colgado, engines sin `dispose()` o consumers sin `stop()`.
- **Prefer**: `clear_trace_id()` en `finally`, `engine.begin()/dispose()`, `lifespan` en FastAPI.

---

## Naming y tipado

### PY-NAM-001 — Código interno en inglés; superficie externa según el contrato del micro
- **Rule**: funciones, clases, variables, módulos, constantes internas y nombres de helpers van en inglés. Los mensajes visibles al usuario y las llaves externas del contrato pueden mantenerse en español si así lo exige el servicio.
- **Apply in**: planning, dev, review.
- **Avoid**: mezclar nombres internos como `EVENT_USUARIO_IP_FIELD`.
- **Prefer**: `EVENT_USER_IP_FIELD` con valor externo `'usuarioIp'` si ese es el campo del contrato.

### PY-NAM-002 — Los identificadores deben ser descriptivos y alineados al dominio
- **Rule**: nombres de variables, métodos, atributos, parámetros y módulos deben expresar el concepto de negocio o la responsabilidad técnica real. No se permiten `x`, `tmp`, `obj`, `data`, `df2`, `var`.
- **Apply in**: planning, dev, review.
- **Avoid**: `process(data)`, `tmp_df`, `obj`.
- **Prefer**: `request_ids`, `participant_payments_df`, `updated_exchange_rate_df`.

### PY-NAM-003 — Convenciones Python estándar obligatorias
- **Rule**: módulos, funciones y variables en `snake_case`; clases en `PascalCase`; constantes en `UPPER_SNAKE_CASE`.
- **Apply in**: dev, review.
- **Avoid**: `Participant_mapper.py`, `traceId` como variable interna Python, `eventUserField`.
- **Prefer**: `participant_mapper.py`, `trace_id`, `EVENT_USER_FIELD`.

### PY-NAM-004 — Las funciones públicas y boundaries deben declarar type hints
- **Rule**: handlers, servicios, helpers públicos, config objects y mappers con interfaz reusable deben exponer type hints explícitos en parámetros y retorno.
- **Apply in**: planning, dev, review.
- **Avoid**: helpers públicos sin tipo alguno cuando son parte del flujo principal.
- **Prefer**: `def execute_migration(...) -> dict`, `def get_connection_string(self) -> str`.

---

## Contrato y validación

### PY-CON-001 — El contrato real del evento/request debe estar alineado con el parser del boundary
- **Rule**: el boundary debe soportar de forma explícita el/los wrappers aprobados (evento directo, SQS, EventBridge, `detail.body`, etc.) y la implementación debe mantenerse alineada con el contrato vigente.
- **Apply in**: planning, dev, review.
- **Avoid**: parsear `Records[0]['body']` “por intuición” sin helper dedicado ni cobertura.
- **Prefer**: helpers de parseo como `_parse_event_body`, `_extract_event_parameters`, `_process_sqs_record`.

### PY-CON-002 — La metadata del evento se normaliza en un solo punto
- **Rule**: `traceId`, `usuarioId`, `usuarioIp` y demás metadata funcional se resuelven/normalizan en un helper o boundary dedicado; el resto del flujo consume esa forma normalizada.
- **Apply in**: planning, dev, review.
- **Avoid**: accesos dispersos a `event['metadata']`, `event['metadatos']`, `payload['detail']` en múltiples funciones.
- **Prefer**: un parser único que devuelva metadata homogénea para el servicio.

### PY-CON-003 — Validar y sanitizar temprano campos requeridos e IDs
- **Rule**: antes de tocar BD, SQS u otros adapters, el boundary debe validar requeridos, coerción a lista si aplica, longitudes, tipos y vacíos del payload.
- **Apply in**: planning, dev, review.
- **Avoid**: dejar que `request_id`, `batch_ids` o `liquidationBatchId` inválidos avancen hasta capas profundas.
- **Prefer**: helpers tipo `_sanitize_and_extract_request_ids`, `_coerce_to_list`, guard clauses de parámetros faltantes.

### PY-CON-004 — La metadata de origen se preserva; no se inventa con defaults hardcodeados
- **Rule**: los campos de metadata operativa deben venir del evento/contexto o de configuración aprobada; no se deben “rellenar” con `USER`, `USER_IP`, identificadores de prueba u otros defaults hardcodeados.
- **Apply in**: planning, dev, review.
- **Avoid**: publishers que mutan metadata para meter `USUARIO_PRUEBA`, `127.0.0.1` o equivalentes.
- **Prefer**: enriquecer desde metadata normalizada del evento o fallar/controlar si el contrato los requiere y faltan.

---

## Observabilidad y errores

### PY-OBS-001 — Toda ejecución debe tener lifecycle completo de `trace_id`
- **Rule**: generar o recuperar `trace_id` al inicio, propagarlo por logs y funciones clave, y limpiarlo/cerrarlo al final de la ejecución.
- **Apply in**: planning, dev, review.
- **Avoid**: `trace_id` opcional que desaparece en helpers intermedios o nunca se limpia.
- **Prefer**: `set_trace_id()`, `get_trace_id()`, `clear_trace_id()` o `trace_prefix`.

### PY-OBS-002 — Los logs deben registrar pasos y contexto de negocio, no payloads crudos
- **Rule**: loguear fases, IDs de negocio, contadores y estado del flujo; evitar loguear eventos completos, secretos, PII o DataFrames enteros.
- **Apply in**: dev, review.
- **Avoid**: `logger.info(f"Event: {json.dumps(event)}")`, logs con solicitudes completas o dumps masivos de DataFrame.
- **Prefer**: logs de `trace_id`, `request_ids`, `batch_ids`, conteos y etapas del ETL.

### PY-OBS-003 — Los errores deben mapearse de forma consistente y con contexto suficiente
- **Rule**: si se atrapa una excepción, debe loguearse con contexto útil y luego re-lanzarse o mapearse a la respuesta/estado canónico del servicio; no ocultar la causa con mensajes ambiguos.
- **Apply in**: planning, dev, review.
- **Avoid**: `except Exception: return []` sin contexto o errores genéricos que borran el `trace_id`.
- **Prefer**: respuesta estructurada o re-raise con logging contextual.

### PY-OBS-004 — Los tests deben cubrir el lifecycle de observabilidad y error path
- **Rule**: cuando el servicio maneja `trace_id`, logging contextual o mapping de errores, los tests del handler deben cubrir tanto el happy path como el error path de ese lifecycle.
- **Apply in**: dev, review.
- **Avoid**: probar solo el caso feliz del handler si el servicio depende de `trace_id`/cleanup.
- **Prefer**: tests de `set_trace_id`, `clear_trace_id`, error 500 y respuestas con contexto mínimo.

---

## Configuración y seguridad

### PY-CFG-001 — Toda configuración sensible u operativa vive en env vars/settings/SSM
- **Rule**: credenciales, hostnames, puertos, nombres de queues, buckets, tópicos, flags y demás configuración operativa se leen desde env vars, settings, Parameter Store/SSM o config centralizada.
- **Apply in**: planning, dev, review.
- **Avoid**: credenciales o URLs embebidas en código productivo.
- **Prefer**: `os.getenv(...)`, config objects centralizados, SSM para secretos.

### PY-CFG-002 — No hardcodear `path`, `key`, `url`, queue names ni endpoints
- **Rule**: ningún `path`, `key`, `url`, endpoint, queue/bucket/topic o equivalente operativo puede quedar hardcodeado en el código productivo; además, el nombre de la env var debe estar en inglés y reflejar el dominio/capacidad.
- **Apply in**: planning, dev, review.
- **Avoid**: `SQS_QUEUE_URL = "https://..."`, `bucket = "mi-bucket-qa"`.
- **Prefer**: `SQS_QUEUE_URL`, `NOTIFICATIONS_QUEUE_URL`, `PAYMENTS_REPORTS_BUCKET_PATH`.

### PY-CFG-003 — La metadata operativa no se hardcodea en publishers o mensajes
- **Rule**: campos como `user`, `userIp`, `traceId`, `eventType` o equivalentes deben venir del contrato/configuración aprobada; no se codifican con valores de prueba o placeholders técnicos.
- **Apply in**: planning, dev, review.
- **Avoid**: constantes `USER = 'USUARIO_PRUEBA'`, `USER_IP = '127.0.0.1'`.
- **Prefer**: resolver desde metadata normalizada o settings explícitos del dominio.

### PY-CFG-004 — El bootstrap técnico se centraliza en módulos de config/container
- **Rule**: logging, engine/DB config, publishers, clients AWS y dependency containers deben centralizarse en módulos de configuración o container del repo.
- **Apply in**: planning, dev, review.
- **Avoid**: repetir bootstrap de boto3/SQLAlchemy/logging en múltiples handlers y helpers.
- **Prefer**: `PostgreSQLConfig`, `get_logger`, `Container`, `SqsBaseConfig`.

---

## Mapping y transformación

### PY-MAP-001 — Los mappers/transformers encapsulan la conversión y normalización, no el I/O
- **Rule**: la lógica de transformación, deduplicación, construcción de llaves y normalización vive en módulos de `transform/` o `mapper/`; no hacen lecturas/escrituras ni publican mensajes.
- **Apply in**: planning, dev, review.
- **Avoid**: mappers que consultan BD o publican SQS.
- **Prefer**: `tpag_*`, `tliq_*`, `ParticipantMapper`, funciones puras sobre DataFrames/modelos.

### PY-MAP-002 — Los transformadores deben ser deterministas y side-effect free
- **Rule**: dada la misma entrada, un transformer debe producir la misma salida y no mutar recursos externos ni depender de estado oculto.
- **Apply in**: dev, review.
- **Avoid**: transformaciones que abren conexiones, leen env vars en caliente o actualizan metadata compartida.
- **Prefer**: funciones puras que reciben `DataFrame`/modelos y retornan nuevos `DataFrame`/estructuras.

### PY-MAP-003 — Validar inputs y devolver resultados explícitos cuando no hay datos
- **Rule**: las transformaciones y mappers deben validar `None`, tipos, columnas requeridas y casos vacíos, devolviendo un resultado explícito (por ejemplo DataFrame vacío con schema) en vez de `None`.
- **Apply in**: dev, review.
- **Avoid**: `return None` para “no había datos” si el resto del flujo espera un DataFrame.
- **Prefer**: `pd.DataFrame(columns=[...])`, dict vacío o respuesta explícita según el contrato interno.

### PY-MAP-004 — Las normalizaciones repetibles se centralizan en el mapper/transformer
- **Rule**: `uppercase`, `trim`, dedupe, construcción de keys, validación de columnas y resoluciones de lookup repetibles deben quedar en helpers/mappers dedicados, no regadas por el flujo.
- **Apply in**: planning, dev, review.
- **Avoid**: repetir `.str.strip().str.upper()` o construcción de llaves en distintos handlers.
- **Prefer**: `_convert_text_to_uppercase`, `build_participant_key`, `_clean_people_dataframe`.

---

## Persistencia y SQL

### PY-SQL-001 — La lógica de acceso a datos vive en `extract`, `load`, repositories o connectors
- **Rule**: queries, inserts, upserts, updates y access patterns a BD deben vivir fuera del handler y fuera de la capa de transformación.
- **Apply in**: planning, dev, review.
- **Avoid**: SQL inline en el boundary principal o dentro de transformadores.
- **Prefer**: `extract.py`, `load.py`, repositories/adapters especializados.

### PY-SQL-002 — Los valores dinámicos se parametrizan; los identificadores dinámicos solo salen de constantes internas
- **Rule**: los valores provenientes del flujo se pasan como parámetros seguros. Solo se aceptan `table_name`, `schema`, `pk_column` o equivalentes dinámicos si provienen de constantes/whitelists internas del código.
- **Apply in**: dev, review.
- **Avoid**: concatenar input del evento/usuario dentro del SQL.
- **Prefer**: `text(...)` + parámetros nombrados para valores.

### PY-SQL-003 — Las cargas masivas y conflictos se resuelven en la capa de carga
- **Rule**: inserciones por lote, `upsert`, deduplicación, `COPY`, `on_conflict` y actualización por PK se definen en `load`/repositories con estrategia explícita.
- **Apply in**: planning, dev, review.
- **Avoid**: handlers que deciden cómo hacer `upsert` fila por fila.
- **Prefer**: `load_df_if_not_exists`, `upsert_on_conflict_do_update`, `load_participant_upsert`.

### PY-SQL-004 — El lifecycle del engine/conexión/transacción debe ser explícito y verificable
- **Rule**: creación, uso y cierre de engines/conexiones deben quedar delimitados con `begin()`, context managers, `dispose()` y tests cuando el repo ya controla ese lifecycle.
- **Apply in**: planning, dev, review.
- **Avoid**: engines huérfanos o conexiones abiertas en helpers utilitarios.
- **Prefer**: `engine.begin()`, `with engine.connect()`, `finally: engine.dispose()`.

---

## Testing

### PY-TST-001 — Todo cambio Python debe traer `pytest` de happy path y error path relevante
- **Rule**: cada cambio funcional debe cubrir al menos el caso feliz y un error/path de borde realmente importante para el flujo.
- **Apply in**: dev, review.
- **Avoid**: tests solo de import o solo de getters cuando cambió comportamiento real.
- **Prefer**: tests que prueben parseo, validación, transformación, carga o publicación según el cambio.

### PY-TST-002 — La estructura de tests replica la estructura del código
- **Rule**: el repo debe mantener tests por capa/componente (`handler`, `extract`, `transform`, `load`, `utils`, `services`, `repositories`, `domain`, `infrastructure`) cuando ese patrón ya exista.
- **Apply in**: planning, dev, review.
- **Avoid**: meter todos los tests nuevos en un único archivo genérico.
- **Prefer**: ubicar el test al lado conceptual de la pieza cambiada.

### PY-TST-003 — Los handlers deben probar wrappers, validación temprana, error mapping y trace lifecycle
- **Rule**: si el cambio toca el boundary, los tests del handler deben cubrir wrappers de evento soportados, sanitización/validación temprana, mapping de errores y lifecycle de `trace_id`.
- **Apply in**: dev, review.
- **Avoid**: probar solo `statusCode == 200`.
- **Prefer**: tests como `test_lambda_handler_trace_id_on_error`, eventos con `Records`, metadata faltante, request IDs inválidos.

### PY-TST-004 — Transformadores, servicios y mappers con lógica real deben probar vacíos, nulls, dedupe y normalización
- **Rule**: cualquier pieza que haga normalización, grouping, resolución de FKs, deduplicación o cálculo debe tener tests propios de edge cases.
- **Apply in**: dev, review.
- **Avoid**: cubrir solo el caso feliz de una transformación compleja.
- **Prefer**: tests de `None`, DataFrame vacío, columnas faltantes, duplicados, valores inválidos y errores controlados.

### PY-TST-005 — Los mappers 1-a-1 no necesitan test aislado; los no triviales sí
- **Rule**: helpers/mappers estrictamente 1-a-1 pueden quedar cubiertos indirectamente por handler/service/usecase. Si el mapper tiene lookup logic, normalización, dedupe, condiciones, cálculos o cambios estructurales, sí requiere test unitario específico.
- **Apply in**: planning, dev, review.
- **Avoid**: exigir tests aislados para un passthrough trivial o, al revés, no testear un mapper con lógica de resolución compleja.
- **Prefer**: test unitario directo solo cuando el mapper agrega valor funcional real.

---

## Runtime y packaging

### PY-RUN-001 — Todo proyecto Python debe declarar `pyproject.toml` como fuente de tooling
- **Rule**: la versión de Python, configuración de `pytest`, `coverage` y demás tooling del repo deben quedar declaradas en `pyproject.toml`.
- **Apply in**: planning, dev, review.
- **Avoid**: depender de configuración implícita de la máquina del desarrollador.
- **Prefer**: `pyproject.toml` con `pythonpath`, `testpaths`, `coverage`, versión Python y tooling del repo.

### PY-RUN-002 — Los Lambdas y servicios deben mantener alineado su runtime operativo
- **Rule**: si el servicio es Lambda, `template.yaml`/`samconfig*` deben acompañar cualquier cambio de runtime, env vars, tags, VPC o handler. Si es FastAPI, el entrypoint y lifecycle (`lifespan`, middleware, handler Mangum/uvicorn) deben mantenerse consistentes.
- **Apply in**: planning, dev, review.
- **Avoid**: cambiar Python, variables o handlers sin tocar los artefactos operativos.
- **Prefer**: diff coordinado entre código, `template.yaml`, `samconfig*`, `Dockerfile`, `k8s/` o entrypoint.

### PY-RUN-003 — Respetar la versión de Python declarada por cada repo
- **Rule**: no asumir que todos los micros Python corren la misma versión. El cambio debe respetar la versión declarada por el servicio (`3.12`, `3.9`, etc.) y sus dependencias compatibles.
- **Apply in**: planning, dev, review.
- **Avoid**: usar features de 3.12 en un micro aún fijado a 3.9.
- **Prefer**: validar `pyproject.toml`, `template.yaml` y tooling del repo antes de introducir features/runtime específicos.

---

## Calidad

### PY-QLT-001 — Evitar handlers gigantes; extraer fases y helpers con responsabilidad semántica
- **Rule**: si el flujo crece, dividirlo en fases/helpers/use cases con nombres del dominio en vez de seguir acumulando lógica en el handler.
- **Apply in**: planning, dev, review.
- **Avoid**: `lambda_handler` monolítico con cientos de líneas de extracción, transformación, carga y publicación mezcladas.
- **Prefer**: `_process_phase1_basic_dimensions`, `_post_process_and_notify`, `ETLService`, `PaymentGroupingService`.

### PY-QLT-002 — No dejar código muerto, comentarios obsoletos ni bloques comentados
- **Rule**: todo diff debe remover imports no usados, comentarios viejos, código comentado y helpers temporales que ya no aportan.
- **Apply in**: dev, review.
- **Avoid**: comentarios “TODO”, bloques enteros comentados o duplicados que quedaron tras el refactor.
- **Prefer**: código limpio, explícito y con el mínimo ruido.

### PY-QLT-003 — No mutar inputs compartidos salvo que el contrato interno lo haga explícito
- **Rule**: payloads, metadata y estructuras compartidas deben tratarse como input inmutable por defecto. Si hay que enriquecerlas, trabajar sobre copias o construir una nueva estructura.
- **Apply in**: dev, review.
- **Avoid**: modificar en sitio `metadata` recibida del evento para inyectar defaults técnicos o datos laterales.
- **Prefer**: `normalized_metadata = {**metadata, 'traceId': trace_id}` o builders equivalentes.

### PY-QLT-004 — No cerrar ni aprobar sin evidencia real de checks del repo
- **Rule**: todo cambio Python debe reportar los checks realmente ejecutados del repo (`pytest`, coverage, `black`, `isort`, `mypy`, `ruff`, `sam build` u otros equivalentes) cuando apliquen al alcance del cambio.
- **Apply in**: dev, review.
- **Avoid**: aprobar “por inspección” sin evidencia de pruebas/checks.
- **Prefer**: listar comandos corridos y resultado relevante en el cierre/review.

---

## References
- `.ai-kit/references/python-smartpay-reference.md`
- `.ai-kit/references/delivery-flow.md`
- `.ai-kit/skills/dev-python/SKILL.md`
- `.ai-kit/skills/review/SKILL.md`
