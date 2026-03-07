# Contexto General (multi-proyecto)

Este directorio conserva solo referencias que agregan valor real al kit: baseline operativo compartido, rulebooks por stack, plantillas puntuales y guías SDD.

## Source of truth

- Reglas del repo: `AGENTS.md` + `context/` local.
- Baseline operativo compartido: `.ai-kit/references/delivery-flow.md`.
- Reglas canónicas de implementación: `./.ai/skills/dev-java/SKILL.md` o `./.ai/skills/dev-python/SKILL.md`.
- Reglas canónicas de review: `./.ai/skills/review/SKILL.md`.
- Rulebook Java: `.ai-kit/references/java-smartpay-rulebook.md`.
- Referencia Java de artefactos: `.ai-kit/references/java-smartpay-reference.md`.
- Referencia Python consolidada: `.ai-kit/references/python-smartpay-reference.md`.
- Flujo SDD: `.ai-kit/references/sdd/sdd-playbook.md`.

## Cómo usar estas referencias

- Para una HU o change SDD: cargar primero `AGENTS.md`, luego el skill correspondiente y después solo la referencia puntual que haga falta.
- Las reglas normativas viven en `dev-java`, `dev-python` y `review`; el rulebook Java existe para mapearlas con IDs y reducir ambigüedad.
- `delivery-flow.md` centraliza el baseline operativo que antes se repetía entre planning, dev y review.
- `java-smartpay-reference.md` y `python-smartpay-reference.md` concentran plantillas y ejemplos auxiliares para evitar muchos `.md` pequeños.

