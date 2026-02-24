# Plantilla – Contexto de HU (AI Kit)

Copia este contenido en:
- `context/hu/<HU_ID>/contrato.md`

Referencias:
- Reglas del repo: `AGENTS.md`
- Reglas comunes: `.ai-kit/references/java-rules.md` o `.ai-kit/references/python-rules.md`
- Guía SDD y prompts: `.ai-kit/references/hu-prompts-and-template-usage.md`

---

# HU-<HU_ID> – <Título corto y claro>

## 1. Resumen ejecutivo
- Objetivo:
- Resultado esperado (cambio observable para usuario/sistema):
- KPI/criterio de éxito:

## 2. Alcance y fuera de alcance
- Alcance:
- Fuera de alcance:

## 3. Suposiciones y dependencias
- Sistemas/colas implicadas:
- Feature flags/propiedades:
- Dependencias de datos/tablas (migraciones):

## 4. Reglas de negocio y definiciones
- Reglas clave (criterios, fórmulas, estados, transiciones):
- Definiciones importantes (glosario breve):

## 5. Impacto arquitectónico (Hexagonal)
- Capas afectadas: Dominio | UseCase | Infraestructura (Adapters, SQL, Mappers) | Entry Points (Router/Handler)
- Nuevos/modificados:
  - Modelos de dominio:
  - Puertos (interfaces):
  - Adapters/SQL Providers:
  - Routers/Handlers/DTOs:

## 6. Contrato (API / interfaz)
- Método y ruta (si aplica)
- Headers (traceId)
- Request DTO + validaciones
- Responses: códigos y ejemplos JSON (incluye errores)
- Mapeo `ErrorCode` ↔ HTTP ↔ mensaje

## 7. SQL (si aplica)
- Borrador SQL con named params
- Tablas/índices relevantes

## 8. Logs y constantes
- Mensajes de log (español)
- Literales a centralizar (headers, columnas, estados)

## 9. Plan de pruebas
- Casos felices
- Errores/validaciones
- Bordes (paginación, nulos, límites)
- Por capa: UseCase, SQLProvider, Adapter, Handler/Router

## 10. Riesgos y decisiones
- Riesgos técnicos
- Preguntas abiertas
- Decisiones (ADR si aplica)

