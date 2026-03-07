# Contexto General (multi-proyecto)

Este directorio conserva solo referencias que realmente agregan valor al kit: plantillas, ejemplos puntuales y playbooks SDD.

## Source of truth

- Reglas del repo: `AGENTS.md` + `context/` local.
- Reglas canónicas de implementación: `./.ai/skills/dev-java/SKILL.md` o `./.ai/skills/dev-python/SKILL.md`.
- Reglas canónicas de review: `./.ai/skills/review/SKILL.md`.
- Flujo SDD: `.ai-kit/references/sdd/sdd-playbook.md`.

## Cómo usar estas referencias

- Para una HU o change SDD: cargar primero `AGENTS.md`, luego el skill correspondiente y después solo la referencia puntual que haga falta.
- Evitar duplicar reglas en varias referencias: si una regla es transversal, debe vivir en el skill y no en varios `.md`.
