---
name: planning
description: >
  Coordina planificación cuando el trabajo cruza Java y Python o el stack no está claro.
  Trigger: Scoping/contratos que involucran múltiples servicios/tecnologías o cuando se necesite enrutar a planning-java/planning-python.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.3"
  scope: [root]
  auto_invoke:
    - "Coordinar planning multi-stack"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Planificación (coordinador)

Usa este skill cuando la tarea combine Java y Python o el lenguaje no esté claro.

## Selección de skill
- Si el cambio es solo Java, usar `planning-java`.
- Si el cambio es solo Python, usar `planning-python`.
- Si el cambio mezcla servicios Java y Python, aplicar ambos flujos y coordinar dependencias, contratos y orden de implementación.
- Si el stack no está claro, inspeccionar manifests (`build.gradle*`, `pom.xml`, `pyproject.toml`, `requirements*.txt`, `template.yaml`) antes de planear.

## Reglas mínimas
- Leer `.ai-kit/references/delivery-flow.md` para el baseline operativo compartido.
- Cargar contexto raíz y de servicio antes de planear.
- Entregar primero contrato/interfaz y luego plan de implementación.
- Alinear el planning con el flujo SDD si el repo ya trabaja con `openspec/`.
- `planning-java` y `planning-python` son las fuentes canónicas del planning; este skill solo enruta.
- No gestionar git, ramas o PRs salvo petición explícita del usuario.

