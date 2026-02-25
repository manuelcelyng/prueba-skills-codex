# Java Playbook (Hexagonal + Reactivo)

## Propósito
Guía operativa para ejecutar HUs en servicios Java con arquitectura Hexagonal/Clean y stack reactivo (WebFlux/R2DBC).

## Reglas no negociables (resumen)
- Hexagonal: **dominio primero**; dependencias apuntan al dominio.
- Reactivo end-to-end: prohibido bloquear (`.block()`, `Thread.sleep`, JDBC).
- Código en inglés; logs/mensajes Swagger/respuestas en español.
- Literales (logs, headers, columnas, estados) en `Constants` del dominio.
- Errores hacia arriba como `BusinessException` + `ErrorCode` del micro (prefijo del servicio).
- SQL parametrizado con parámetros nombrados; nunca concatenar input.
- Tests mínimos por HU: UseCase, SQL Provider (estructura), Adapter, Handler/Router.

## Arquitectura por capas
- **Domain**: modelos + puertos + `BusinessException/ErrorCode`. Sin Spring.
- **UseCase**: orquestación de puertos y reglas de aplicación. Sin DTOs de API.
- **Infrastructure**: implementa puertos, SQL providers, mappers.
- **Entry points**: routers/handlers, validación, `traceId`, contrato API.

## Flujo HU (TDD)
1. Leer HU y contrato (si existe) en `context/hu/<HU_ID>/`.
2. Definir/confirmar **contrato API** (códigos + ejemplos JSON).
3. Definir **plan de implementación** (capas + borrador SQL con named params).
4. Tests (happy path + errores) → implementar UseCase → adapter/SQL provider → handler/router.
5. Validar ErrorCodes, logs y OpenAPI.
6. Ejecutar tests (`./gradlew test`) y refactorizar.

## Nomenclatura recomendada
- UseCase: `*UseCase`
- Puertos: `*Port` / `*Gateway`
- Infra: `*Adapter`, `*SQLProvider`, `*Mapper`
- API: `*Handler`, `*Router`

## Checklist HU (rápido)
- [ ] Contrato con códigos y ejemplos JSON (incluye errores).
- [ ] Plan con SQL borrador (named params) y cambios por capa.
- [ ] Sin bloqueos en Reactor.
- [ ] SQL parametrizado; literales en `Constants`.
- [ ] Errores mapeados a `BusinessException/ErrorCode`.
- [ ] Tests agregados/actualizados (UC/SQL/Adapter/API).

## Referencias
- `.ai-kit/references/java-rules.md`
- `.ai-kit/references/java-code-quality.md`
- `.ai-kit/references/java-api-examples.md`

