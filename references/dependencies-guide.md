# Dependencies Guide (Java)

## Purpose
Mantener dependencias justificadas, compatibles con Java 21 y con el modelo reactivo (WebFlux/R2DBC), evitando bloat y conflictos transitivos.

## Reglas
1. **Justificar** cada dependencia nueva (qué problema resuelve).
2. **Verificar compatibilidad** con Java 21 y stack reactivo.
3. **Evaluar impacto** (tamaño artefacto, performance, operatividad).
4. **Revisar seguridad** (CVEs críticos) y transitive deps.
5. **Documentar** cambios estratégicos con ADR.
6. **Eliminar** dependencias obsoletas cuando el refactor lo permita.

## Checklist para nueva dependencia
- [ ] Alternativa ya existe en el proyecto.
- [ ] Se requiere realmente (no “por si acaso”).
- [ ] Compatible Java 21 / WebFlux / R2DBC.
- [ ] Conflictos transitivos evaluados (exclusions si aplica).
- [ ] Impacto aceptable (memoria/latencia/size).
- [ ] (Si aplica) ADR creado/actualizado.

