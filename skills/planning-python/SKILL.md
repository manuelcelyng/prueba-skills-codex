---
name: planning-python
description: >
  Planifica cambios para servicios Python (lambda-* / FastAPI).
  Trigger: Cuando se necesita contrato de interfaz/evento y plan de implementación antes de desarrollar.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.3"
  scope: [root]
  auto_invoke:
    - "Planificar HU / contrato"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Planning Python

Planear cambios Python y dejar el material listo para que `dev-python` implemente y `review` audite sin ambigüedad.

## Shared Operating Model

Leer `.ai-kit/references/delivery-flow.md` antes de producir artefactos. Ese documento define contexto mínimo, gates HU/SDD, write locations y evidencia esperada para pasar a implementación y review.

## Deliverables (mandatory order)

1. Contexto, alcance, supuestos y fuera de alcance.
2. **Contrato de interfaz/evento** completo.
3. **Plan de implementación** por capas/componentes con SQL o explicación explícita si no aplica.
4. Checklist final de “listo para implementar con `dev-python`”.

## Contract Requirements

El contrato debe dejar explícito:
- tipo de interfaz (HTTP, evento, batch/ETL);
- payloads/request/response con validaciones;
- códigos de respuesta o estados lógicos, con ejemplos JSON cuando aplique;
- errores esperados y trazabilidad (`trace_id` o equivalente);
- impacto en configuración o runtime.

## Implementation Plan Requirements

El plan debe dejar explícito:
- módulos o capas afectados (`domain`, `application`, `infrastructure`, ETL, routers, handlers, etc.);
- persistencia/consultas y estrategia segura de acceso a datos;
- logging, validaciones, env vars y secretos;
- impacto en `pyproject.toml`, `template.yaml`, SAM/K8s o manifests;
- estrategia de pruebas y cobertura esperada.

## Handoff to Implementation

No marques el planning como listo si falta alguno de estos puntos:
- contrato con payloads y errores suficientes;
- plan técnico por componentes;
- tratamiento de trazabilidad/configuración;
- estrategia de persistencia segura;
- estrategia de pruebas verificable.

## References
- `.ai-kit/references/delivery-flow.md`
- `.ai-kit/references/python-smartpay-reference.md`
- `.ai-kit/references/sdd/sdd-playbook.md`

