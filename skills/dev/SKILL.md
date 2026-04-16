---
name: dev
description: >
  Coordina desarrollo cuando el trabajo cruza Java y Python o el stack no está claro.
  Trigger: Cambios que tocan múltiples servicios/tecnologías o cuando se necesite enrutar a dev-java/dev-python.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.3"
  scope: [root]
  auto_invoke:
    - "Coordinar implementación multi-stack"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Desarrollo (coordinador)

Usa este skill cuando la tarea combine Java y Python o el lenguaje no esté claro.

## Selección de skill
- Si el cambio es solo Java, usar `dev-java`.
- Si el cambio es solo Python, usar `dev-python`.
- Si el cambio mezcla servicios Java y Python, aplicar ambos flujos y coordinar dependencias, contratos y orden de despliegue.
- Si el stack no está claro, inspeccionar manifests (`build.gradle*`, `pom.xml`, `pyproject.toml`, `requirements*.txt`, `template.yaml`) antes de implementar.

## Reglas mínimas
- Leer `references/delivery-flow.md` para el baseline operativo compartido.
- Cargar contexto raíz y del servicio antes de implementar.
- No codificar sin contrato + plan o sin artefactos SDD aprobados.
- Tomar `dev-java` y `dev-python` como fuentes canónicas de reglas de implementación; este skill solo enruta.
- En integraciones entre microservicios, alinear contratos, configuración y evidencia de pruebas en ambos lados.
- No gestionar git, ramas o PRs salvo petición explícita del usuario.

