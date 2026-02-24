---
name: asulado-router
description: Orquesta y enruta el trabajo con IA (SDD) hacia planning/dev/review según el tipo de tarea y el stack del repo.
metadata:
  scope: root
  auto_invoke:
    - "Enrutar tarea (orquestador)"
---

# ASULADO Router (Orchestrator / SDD)

Usa este skill como punto de entrada para enrutar la tarea al skill correcto y exigir el flujo **SDD**:

1) **Contexto** → leer `AGENTS.md` y `context/` del repo.
2) **Contrato + plan** → si aplica HU/endpoint/SQL, exigir contrato y plan antes de implementar.
3) **Ejecución** → delegar a `dev-java` o `dev-python`.
4) **Verificación** → delegar a `review` cuando pidan auditoría/code review o al cerrar una HU.

## Routing de skills (reglas)

- Si la solicitud es “planificar / contrato / HU / alcance / diseño”: invocar `planning-java` o `planning-python`.
- Si la solicitud es “implementar / fix / refactor / agregar endpoint”: invocar `dev-java` o `dev-python`.
- Si la solicitud es “review / checklist / validar cumplimiento / auditoría”: invocar `review`.
- Si la solicitud es “crear un skill”: invocar `skill-creator` y al final `skill-sync`.

## Persistencia (Engram portable)

La persistencia del conocimiento vive en el repo del servicio:
- Contratos y planes en `context/hu/<HU_ID>/...` (o la convención existente del repo).
- Decisiones en `context/adr_*.md` (si aplica).

No dependas de memoria del asistente como única fuente de verdad.
