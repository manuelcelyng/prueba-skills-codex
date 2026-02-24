---
name: review
description: Revisa cambios y valida cumplimiento de reglas y planificacion en este workspace (Java y Python). Usar para auditorias, validaciones de HUs o code review; debe cargar contextos raiz y de servicio.
metadata:
  scope: root
  auto_invoke:
    - "Revisar cambios"
---

# Review Skill

Usa este skill para code review y validacion de cumplimiento.

## Carga de contexto obligatoria
1. Leer `AGENTS.md`.
2. Leer `.ai-kit/references/context-readme.md`.
3. Leer `.ai-kit/references/java-rules.md`.
4. Leer `.ai-kit/references/python-rules.md`.
5. Leer `context/` del repo si existe (especialmente `context/agent-master-context.md`).
6. Leer HU y contratos/planes asociados si se revisan cambios de una HU (`context/hu/<HU_ID>/`).

## Verificaciones de documentacion y planning
- Existe contrato con codigos de respuesta y ejemplos JSON para todas las respuestas.
- Existe plan de implementacion con SQL borrador o explicacion si no aplica SQL.
- El contrato precede al plan de implementacion en la HU.
- `error-codes.md` actualizado si se agregan codigos.
- ADR o `dependencies_optimized.md` actualizado cuando aplica.

## Verificaciones Java
- Limites de arquitectura (dominio/usecase/infra/entry points).
- Reactividad end-to-end; sin `.block()` ni JDBC.
- Puertos/gateways: sufijo `Port` (no `*Repository` para puertos).
- UseCase naming: evitar prefijos `Get*`/`Query*` en HU nuevas; evitar metodos `execute`; exigir nombres descriptivos del caso de uso.
- Regla de refactor: todo componente desacoplado por el cambio (clases, DTOs, mappers, rutas, tests y constantes sin uso) debe eliminarse; no dejar codigo muerto.
- Literales en `Constants`, logs en espaniol con traceId.
- Regla estricta de strings: reportar hallazgo cuando haya strings hardcodeados en adapters/usecases/providers (incluye nombres de parametros de bind SQL como `batchId`, nombres de columnas o claves tecnicas); exigir extraccion a constantes.
- Errores como `BusinessException` con `ErrorCode`.
- SQL Providers con parametros nombrados.
- SQL Providers: alias explicitos y legibles en `SELECT` (evitar queries "opacas" sin `AS` o alias ambiguos).
- Alias SQL en `snake_case` (minusculas con `_`) para columnas derivadas/mapeadas.
- MapStruct y sin logica de negocio en mappers/adapters/routers.
- En adapters R2DBC, el mapeo `row -> modelo` debe delegarse en `*RowMapper`; reportar hallazgo si el adapter construye modelos/respuestas directamente.
- Modelos: no usar sufijos `Row` en dominio; modelos de mapeo/lectura deben vivir en infraestructura.
- Validaciones: deben ser Bean Validation en DTO de entrada + `ValidatorEngine`/traducciones (sin constantes custom de path/mensaje); evitar validaciones manuales en handlers/usecases salvo regla estrictamente de negocio.
- Naming adapters: evitar nombres que mezclen conceptos (`RepositoryAdapter`); usar `*Adapter` (sin sufijo `R2dbc` salvo multiples implementaciones del mismo `Port`).
- Imports: prohibido usar FQCN inline en el cuerpo (importar al inicio).
- Reportar uso de `@SuppressWarnings` en código productivo sin justificación técnica explícita y acotada.
- Tests de UseCase, SQL Provider, Adapter y Handler/Router.
- Tests HU: SUT con `@InjectMocks` y datos/strings centralizados en `*TestData` (sin hardcode inline).
- Reglas especificas del servicio (p. ej., en `dispersion` no usar comentarios inline).

## Verificaciones Python
- Arquitectura segun servicio (ETL, domain/application/infrastructure, FastAPI).
- Logging con `trace_id` y helpers cuando existan.
- Configuracion por env/SSM; sin hardcode de secretos.
- Formato con black/isort/mypy segun `pyproject.toml`.
- Version de Python correcta para el servicio.
- Tests con pytest y cobertura >=80% cuando aplique.

## Output
- Entregar hallazgos primero y ordenados por severidad.
- Usar referencias de archivo y lineas; emitir `::code-comment{...}` para hallazgos puntuales.
- Luego listar preguntas o supuestos.
- Cerrar con un resumen corto si es necesario.

## Referencias
    - `references/review-checklist.md`
