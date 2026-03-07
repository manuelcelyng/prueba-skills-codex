---
name: planning-python
description: >
  Planifica cambios para servicios Python (lambda-* / FastAPI).
  Trigger: Cuando se necesita contrato de interfaz/evento y plan de implementación antes de desarrollar.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.2"
  scope: [root]
  auto_invoke:
    - "Planificar HU / contrato"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Planear cambios Python y dejar el material listo para que `dev-python` implemente y `review` audite sin ambigüedad.

## Required Context (load order)

1. Leer `AGENTS.md`, `README.md` y `context/` relevante del servicio.
2. Leer `./.ai/skills/dev-python/SKILL.md` y `./.ai/skills/review/SKILL.md` como reglas canónicas.
3. Si existe `openspec/changes/<change-name>/`, alinear la HU con `proposal/spec/design/tasks`.
4. Si hay HU, leer `context/hu/<HU_ID>/` y artefactos existentes.
5. Revisar `pyproject.toml`, `requirements*.txt`, `template.yaml` y manifests relevantes.

## Output Order (mandatory)

1. Contexto, alcance, supuestos y fuera de alcance.
2. **Contrato de interfaz/evento** completo.
3. **Plan de implementación** por capas/componentes con SQL o explicación explícita si no aplica.
4. Checklist final de “listo para implementar con `dev-python`”.

## Contract Requirements

El contrato debe incluir:
- tipo de interfaz (HTTP, evento, batch/ETL);
- payloads/request/response con validaciones;
- códigos de respuesta o estados lógicos, con ejemplos JSON cuando aplique;
- errores esperados y trazabilidad (`trace_id` o equivalente);
- impacto en configuración o runtime.

## Implementation Plan Requirements

El plan debe dejar explícito:
- módulos/capas afectados (`domain`, `application`, `infrastructure`, ETL, routers, handlers, etc.);
- persistencia/consultas y estrategia segura de acceso a datos;
- logging, validaciones, env vars y secretos;
- impacto en `pyproject.toml`, `template.yaml`, SAM/K8s o manifests;
- estrategia de pruebas y cobertura esperada.

## Where to Write

- Contrato: `context/hu/<HU_ID>/contrato.md` (o archivo equivalente existente).
- Plan: `context/hu/<HU_ID>/plan-implementacion.md` (o archivo equivalente existente).
- Si el cambio ya usa SDD, reflejar el mismo alcance en `openspec/changes/<change-name>/`.

## References

- `.ai-kit/references/contract-template-python.md`
- `.ai-kit/references/plan-template-python.md`
- `.ai-kit/references/sdd/sdd-playbook.md`

## Limits

- No gestionar git, ramas o PRs.
