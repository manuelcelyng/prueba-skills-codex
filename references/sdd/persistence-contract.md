# SmartPay SDD Persistence Contract

Contrato compartido para todo el flujo SDD del kit. Resume **dónde leer/escribir artefactos**, **cómo recuperar estado** y **qué modo usar**.

## Artifact Store Modes

El orquestador pasa `artifact_store.mode` con uno de estos valores:

- `openspec`
- `engram`
- `none`

## Mode Resolution (SmartPay)

Orden de precedencia:

1. Si el usuario u orquestador fijó un modo explícito, úsalo.
2. Si el usuario pidió “no escribir archivos” o trabajo efímero, usa `none`.
3. Si el perfil del repo es `smartpay`, el default es `openspec`.
4. Usa `engram` solo cuando el usuario lo pida explícitamente o quiera persistencia sin ensuciar el repo.

> Inspiración de Agent Teams Lite: el backend es pluggable. En SmartPay se privilegia `openspec` porque deja trazabilidad visible por microservicio y se alinea con HU/contexto del equipo.

## Behavior Per Mode

| Mode | Lee desde | Escribe en | Archivos del repo |
|------|-----------|------------|-------------------|
| `openspec` | `openspec/` + código + contexto local | `openspec/` | Sí |
| `engram` | Engram + código + contexto local | Engram | No |
| `none` | prompt del orquestador + código + contexto local | Nowhere | No |

## Orchestrator State Persistence

El orquestador debe persistir estado después de cada transición de fase.

| Mode | Persist State | Recover State |
|------|---------------|---------------|
| `openspec` | `openspec/changes/{change-name}/state.yaml` | Leer `state.yaml` |
| `engram` | `mem_save(topic_key: "sdd/{change-name}/state")` | `mem_search` → `mem_get_observation` |
| `none` | No posible | No posible; advertir al usuario |

## Structured Result Contract

Cada fase devuelve este envelope:

```json
{
  "status": "ok | warning | blocked | failed",
  "executive_summary": "resumen corto orientado a decisión",
  "detailed_report": "opcional, más largo cuando haga falta",
  "artifacts": [
    {
      "name": "proposal | spec | design | tasks | verify-report | ...",
      "store": "openspec | engram | none",
      "ref": "file-path | observation-id | null"
    }
  ],
  "next_recommended": ["sdd-spec", "sdd-design"],
  "risks": ["riesgo opcional"]
}
```

## Common Rules

- `openspec` solo escribe en los paths definidos por `openspec-convention.md`.
- `engram` nunca escribe archivos del repo.
- `none` nunca crea archivos ni actualiza artefactos persistentes.
- Si el modo es ambiguo, en SmartPay asume `openspec` salvo instrucción contraria.
- `detail_level` (`concise | standard | deep`) cambia la verbosidad del reporte, no el contenido que se persiste.
- Después de compaction o pérdida de contexto, el orquestador debe **recuperar estado antes de continuar**.
