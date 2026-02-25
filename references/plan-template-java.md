# Plantilla de Plan de Implementación (Java)

## 1) Scope técnico
- Componentes/módulos afectados
- Cambios por capa (Domain/UseCase/Infrastructure/Entry points)

## 2) Modelo y puertos
- Nuevos modelos / cambios
- Puertos nuevos o extendidos (firma)

## 3) Persistencia (SQL / R2DBC)
- Borrador SQL con **named params**
- Parámetros esperados (map)
- Índices/joins si aplica (solo si impacta)

## 4) OpenAPI / contrato
- Cambios de DTOs
- Códigos de respuesta y ejemplos

## 5) Tests
- UseCase: escenarios + mocks
- SQL Provider: estructura del query + params
- Adapter: mapeos y manejo de errores
- Handler/Router: contrato (status/body)

## 6) Riesgos y validación
- Riesgos (performance, compatibilidad, seguridad)
- Comandos de validación (`./gradlew test`, etc.)

