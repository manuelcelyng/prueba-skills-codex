# Plantilla – Contexto de HU (AI Kit)

Copia este contenido en:
- `context/hu/<HU_ID>/contrato.md`

Referencias:
- Baseline operativo: `.ai-kit/references/delivery-flow.md`
- Reglas del repo: `AGENTS.md`
- Reglas canónicas de implementación: `./.ai/skills/dev-java/SKILL.md` o `./.ai/skills/dev-python/SKILL.md`
- Reglas canónicas de review: `./.ai/skills/review/SKILL.md`
- Referencia stack específica: `.ai-kit/references/java-smartpay-reference.md` o `.ai-kit/references/python-smartpay-reference.md`
- Guía SDD: `.ai-kit/references/sdd/sdd-playbook.md`

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

## 5. Impacto arquitectónico
- Capas afectadas: Dominio | UseCase | Infraestructura | Entry Points
- Nuevos/modificados:
  - Modelos de dominio:
  - Puertos/interfaces:
  - Adapters/SQL Providers:
  - Routers/Handlers/DTOs:

## 6. Contrato (API / interfaz)
- Método y ruta (si aplica)
- Headers / correlación (`traceId` o equivalente)
- Request DTO + validaciones
- Responses: códigos y ejemplos JSON (incluye errores)
- Mapeo `ErrorCode` ↔ HTTP ↔ mensaje

## 7. SQL o persistencia (si aplica)
- Borrador SQL con named params o estrategia equivalente segura
- Tablas/índices/repositorios relevantes

## 8. Logs, constantes y observabilidad
- Mensajes de log (español)
- Literales a centralizar (headers, columnas, estados, claves)
- Métricas / trazabilidad adicional

## 9. Plan de pruebas
- Casos felices
- Errores/validaciones
- Bordes (paginación, nulos, límites)
- Por capa/componente: UseCase, SQLProvider, Adapter, Handler/Router o equivalentes

## 10. Riesgos y decisiones
- Riesgos técnicos
- Preguntas abiertas
- Decisiones (ADR si aplica)

