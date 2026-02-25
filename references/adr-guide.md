# ADR Guide (ASULADO)

## Purpose
Mantener un historial auditable de decisiones arquitectónicas (qué se decidió, por qué, alternativas y consecuencias).

## Cuándo crear un ADR
- Se introduce una tecnología nueva (librería/framework).
- Se cambia un patrón base (arquitectura, modelado, persistencia, mensajería).
- Se toma una decisión con trade-offs relevantes (seguridad, performance, costo, operatividad).

## Formato recomendado
- ID: `ADR-XXX`
- Fecha: `YYYY-MM-DD`
- Título
- Contexto / problema
- Decisión
- Alternativas consideradas
- Consecuencias (positivas/negativas)
- Estado: `Propuesto | Aprobado | Rechazado | Obsoleto`

## Plantilla
```md
### ADR-XXX: Título
- Fecha: YYYY-MM-DD
- Contexto: Problema / necesidad / restricción
- Decisión: Qué y por qué
- Alternativas:
  - Opción A: Pros / Contras
  - Opción B: Pros / Contras
- Consecuencias:
  - Positivas: ...
  - Negativas: ...
- Estado: Propuesto
```

## Reglas
1. Evitar micro-implementaciones (solo decisiones estratégicas).
2. Mantener tabla resumen (si existe) consistente con el detalle.
3. Marcar como `Obsoleto` y referenciar ADR reemplazo cuando aplique.

