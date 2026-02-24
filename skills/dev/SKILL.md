---
name: dev
description: Coordina desarrollo en servicios Java y Python del workspace ASULADO. Usar cuando el trabajo cruza lenguajes o el usuario no especifica; derivar a dev-java o dev-python.
metadata:
  scope: root
  auto_invoke:
    - "Implementar cambios"
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
    - `references/skill-routing.md`
