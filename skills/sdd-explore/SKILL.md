---
name: sdd-explore
description: >
  Explora el codebase antes de comprometer una solución. Investiga estado actual, áreas afectadas, riesgos y opciones.
  Trigger: Cuando el orquestador necesita entendimiento real del repo antes de proponer un change.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  scope: [root]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Investigar el código real y devolver análisis estructurado para que proposal/spec/design no nazcan de supuestos.

## Required References

- `references/sdd/persistence-contract.md`
- `AGENTS.md` del repo
- `openspec/config.yaml` si existe

## Workflow

1. Entender el request: feature, bug, refactor o exploración comparativa.
2. Leer código real en las zonas afectadas.
3. Identificar archivos, dominios y dependencias impactadas.
4. Comparar enfoques si existe más de una opción razonable.
5. Persistir `exploration.md` solo si hay `change-name` y el modo es `openspec`.

## Output Format

```markdown
## Exploration: <topic>

### Current State
...

### Affected Areas
- `path` — razón

### Approaches
1. **Option A**
   - Pros:
   - Cons:
   - Effort:

### Recommendation
...

### Risks
- ...

### Ready for Proposal
Yes/No
```

## Rules

- No modificar código del producto.
- El único archivo permitido aquí es `exploration.md` dentro del change folder cuando aplique.
- Siempre leer código y tests reales, no adivinar.
- Devuelve el envelope estructurado.
