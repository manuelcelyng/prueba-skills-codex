# Reglas Java (Clean/Hexagonal + Reactivo)

## Arquitectura y capas
- Hexagonal/Clean: Dominio -> UseCase -> Infraestructura -> Entry Points.
- Dominio sin dependencias de Spring/infra; UseCase solo usa puertos del dominio.
- Infraestructura implementa puertos, mapea DTO/entidades a dominio.
- Entry Points validan input, manejan traceId, invocan UseCase y adaptan respuesta.
- Ningun Adapter debe contener reglas de negocio.

## Reactividad
- WebFlux + R2DBC end-to-end. Prohibido bloquear: `.block()`, `Thread.sleep`, JDBC.
- Usar Mono/Flux correctamente (sin suscripciones anidadas, sin side-effects en mappers).

## Nomenclatura y lenguaje
- Codigo (clases/metodos) en ingles; logs, mensajes y Swagger en espanol.
- Sufijos estandar: `UseCase`, `Gateway/Port`, `Adapter`, `SQLProvider`, `Mapper`, `Handler`, `Router`.

## Constantes y logging
- Literales (logs, headers, columnas, estados) en `Constants` del dominio.
- Logs en espanol, sin PII; incluir `traceId` como primer parametro.
- No concatenar strings con `+` en logs; usar placeholders.

## Errores y codigos
- Errores hacia arriba como `BusinessException` con `ErrorCode` del modulo.
- No propagar `RuntimeException` cruda a entry points.
- Mantener el catálogo de error codes del micro actualizado (skill local o doc del servicio).

## SQL Providers
- Consultas con parametros nombrados; nunca concatenar input.
- Base query completa y `append` solo para filtros opcionales.
- Tests de SQL validan clausulas criticas y mapa de parametros.

## Testing
- Stack comun: JUnit5, Mockito, Reactor Test, WebTestClient, ArchUnit.
- Tests obligatorios por HU: UseCase, SQL Provider, Adapter, Handler/Router.
- Cobertura enfocada en logica y ramas criticas; asserts encadenados.

## Calidad
- Evitar code smells: metodos grandes, >5 parametros, duplicacion, imports `*`.
- Sin logica de negocio en mappers/adapters/routers.
