# Calidad de Código (Java) — reglas prácticas

## Objetivo
Evitar code smells y issues típicos de Sonar/PR desde el inicio.

## Reglas rápidas (alto impacto)
1. **Sin duplicar literales**: si un string/número se repite, extraer constante.
2. **Sin duplicar bloques**: extraer a método privado (DRY).
3. **Sin magic numbers**: usar constantes con nombre.
4. **Sin código comentado**: el historial vive en Git.
5. **Tests con AssertJ encadenado** (no asserts dispersos del mismo objeto).
6. **Tests sin data hardcodeada**: estados/valores de negocio deben venir de `Constants` o `*TestData` (Object Mother).
7. **Reactor sin materializar flujos**: evitar `collectList()` + `Flux::fromIterable` solo para reemitir; preferir streaming (`concatMap` si secuencial/ordenado).
8. **SQL Providers**: query base completa + `append` solo para filtros opcionales; parámetros siempre bind nombrado.
9. **Imports explícitos**: evitar `import x.*`.

## Anti-patrones comunes
- Métodos gigantes o con >5 parámetros (considerar DTO/VO).
- Lógica de negocio en adapters/mappers/routers.
- Bloqueos en Reactor (`.block()`, `Thread.sleep`).
