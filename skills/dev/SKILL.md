---
name: dev
description: >
  Coordina desarrollo cuando el trabajo cruza Java y Python o el stack no está claro.
  Trigger: Cambios que tocan múltiples servicios/tecnologías o cuando se necesite enrutar a dev-java/dev-python.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Coordinar implementación multi-stack"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Desarrollo (coordinador)

Usa este skill cuando la tarea combine Java y Python o el lenguaje no este claro.

## Seleccion de skill
- Si el cambio es solo Java, usar `dev-java`.
- Si el cambio es solo Python, usar `dev-python`.
- Si el cambio mezcla servicios Java y Python, aplicar ambos flujos y coordinar dependencias.

## Reglas minimas
- Cargar contextos raiz y de servicio antes de implementar.
- Verificar contrato y plan antes de codificar.
- En integraciones entre microservicios, definir endpoints consumidos por configuracion y reflejarlos en `application-*.yml` y `deployment/k8s/configsecret.yaml`.
- No gestionar git, ramas o PRs.

## Referencias
- `.ai-kit/references/skill-routing.md`
