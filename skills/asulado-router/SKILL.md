---
name: asulado-router
description: >
  Orquesta y enruta el trabajo con IA (SDD) hacia planning/dev/review según el tipo de tarea y el stack del repo.
  Trigger: Usar como punto de entrada cuando la solicitud sea ambigua o pueda requerir planificación (HU/contrato) antes de implementar.
license: Internal
metadata:
  author: pragma-asulado
  version: "0.1"
  scope: [root]
  auto_invoke:
    - "Enrutar tarea (orquestador)"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Punto de entrada para enrutar la tarea al skill correcto y exigir flujo **SDD**:

1) Contexto: leer `AGENTS.md` del repo/servicio y cargar solo el contexto necesario (HU/contrato/plan si aplica).
2) Contrato + plan: si aplica HU/endpoint/SQL, exigir contrato y plan antes de implementar.
3) Ejecución: delegar a `dev-java` o `dev-python`.
4) Verificación: delegar a `review` al cerrar cambios o cuando pidan auditoría.

## Routing

- Si la solicitud es “planificar / contrato / HU / alcance / diseño”: invocar `planning-java` o `planning-python`.
- Si la solicitud es “implementar / fix / refactor / agregar endpoint”: invocar `dev-java` o `dev-python`.
- Si la solicitud es “review / checklist / validar cumplimiento / auditoría”: invocar `review`.
- Si la solicitud es “configurar IA / sincronizar skills / onboarding”: invocar `ai-setup`.
- Si la solicitud es “crear un skill”: invocar `skill-creator` y al final `skill-sync`.

## Persistencia (Engram portable)

La persistencia del conocimiento vive en el repo del servicio:
- Contratos y planes en `context/hu/<HU_ID>/...` (o la convención existente del repo).
- Decisiones en ADRs del servicio (si existen).

No dependas de memoria del asistente como única fuente de verdad.
