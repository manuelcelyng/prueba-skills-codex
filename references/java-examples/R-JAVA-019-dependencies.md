# R-JAVA-019 — Dependencias (Java 21 + WebFlux/R2DBC)

## ❌ Mal

- Agregar dependencias “por si acaso”.
- Meter librerías que obligan a bloquear (JDBC) en un servicio reactivo.
- No documentar decisiones estratégicas.

## ✅ Bien

- Justificar cada dependencia nueva.
- Verificar compatibilidad con Java 21 + stack reactivo.
- Evaluar impacto (tamaño/performance/CVEs).
- Documentar cambios estratégicos con ADR.

Referencia: `dependencies-guide.md` y `adr-guide.md`.
