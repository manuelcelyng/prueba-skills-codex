# SmartPay SDD Engram Convention

Convención determinística para persistir artefactos SDD en Engram sin depender de búsquedas difusas.

## Naming Rules

Todos los artefactos SDD usan:

```text
title:     sdd/{change-name}/{artifact-type}
topic_key: sdd/{change-name}/{artifact-type}
type:      architecture
project:   {repo o proyecto actual}
scope:     project
```

Excepción: `sdd-init` usa `sdd-init/{project-name}` como `title` y `topic_key`.

> Esto está alineado con el Engram actual: `topic_key` funciona como upsert estable y `scope` debe quedar en `project` para no mezclar memorias personales con artefactos del cambio.

## Artifact Types

| Artifact type | Producido por |
|---------------|---------------|
| `explore` | `sdd-explore` |
| `proposal` | `sdd-propose` |
| `spec` | `sdd-spec` |
| `design` | `sdd-design` |
| `tasks` | `sdd-tasks` |
| `apply-progress` | `sdd-apply` |
| `verify-report` | `sdd-verify` |
| `archive-report` | `sdd-archive` |
| `state` | `smartpay-sdd-orchestrator` |

## Recovery Protocol (mandatory)

Para recuperar un artefacto:

1. `mem_search(query: "sdd/{change-name}/{artifact-type}", project: "{project}")`
2. `mem_get_observation(id: <resultado>)`

No uses previews de `mem_search` como contenido completo; siempre vienen truncados.

## Standard Write

```text
mem_save(
  title="sdd/{change-name}/{artifact-type}",
  topic_key="sdd/{change-name}/{artifact-type}",
  type="architecture",
  project="{project}",
  scope="project",
  content="{markdown completo}"
)
```

## Update Existing Artifact

- Si ya tienes el `id` exacto del artefacto: `mem_update(id=<observation-id>, content="{markdown actualizado}")`
- Si no tienes el `id` pero sí el `topic_key`, `mem_save` con el mismo `topic_key` actualiza el tópico existente.

## State Artifact Example

```yaml
change: add-csv-export
phase: tasks
artifact_store: engram
artifacts:
  proposal: true
  spec: true
  design: true
  tasks: true
  verify-report: false
last_updated: 2026-03-07T12:00:00Z
```

## Rules

- Usa `topic_key` estable para permitir upserts sin duplicados.
- Si una fase produce múltiples dominios, persístelos en un solo artefacto con encabezados claros por dominio.
- El `archive-report` debe dejar lineage de observation IDs cuando sea útil para auditoría.
- Si una decisión evoluciona fuera del flujo SDD, puedes usar `mem_suggest_topic_key` antes de guardar; para artefactos SDD, el naming determinístico de arriba sigue siendo la fuente de verdad.
