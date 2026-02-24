---
name: planning
description: Coordina planificacion para servicios Java y Python del workspace ASULADO. Usar cuando el trabajo cruza lenguajes o el usuario no especifica; derivar a planning-java o planning-python.
metadata:
  scope: root
  auto_invoke:
    - "Coordinar planning multi-stack"
---

# Planificacion (coordinador)

Usa este skill cuando la tarea combine Java y Python o el lenguaje no este claro.

## Seleccion de skill
- Si el cambio es solo Java, usar `planning-java`.
- Si el cambio es solo Python, usar `planning-python`.
- Si el cambio mezcla servicios Java y Python, aplicar ambos flujos y coordinar dependencias.

## Reglas minimas
- Cargar contextos raiz y de servicio antes de planear.
- Entregar primero contrato y luego plan de implementacion.
- No gestionar git, ramas o PRs.

## Referencias
    - `references/skill-routing.md`
