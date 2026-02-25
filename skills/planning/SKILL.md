---
name: planning
description: >
  Coordina planificación cuando el trabajo cruza Java y Python o el stack no está claro.
  Trigger: Scoping/contratos que involucran múltiples servicios/tecnologías o cuando se necesite enrutar a planning-java/planning-python.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Coordinar planning multi-stack"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
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
- `.ai-kit/references/skill-routing.md`
