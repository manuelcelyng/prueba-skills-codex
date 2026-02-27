---
name: azuredevops
description: >-
  Ayuda a iniciar trabajo desde Azure DevOps Boards: listar y priorizar work
  items (Task/Bug/HU), descargar el detalle por ID/link, traer relacionados,
  bajar anexos (AttachedFile) y generar un `context.md` en el repo (por defecto
  `context/hu-{id}/context.md`). Si existe el MCP `azuredevops`, úsalo primero;
  si no, usa el script Python (fallback).
---

# azuredevops

## Objetivo

Mejorar el flujo de “arrancar una tarea”:
1) ver qué work items tengo asignados (o buscar por WIQL),
2) decidir por cuál iniciar,
3) bajar el contexto (detalle + relacionados + anexos) y dejarlo listo en el repo.

## Pre-requisitos (una vez por máquina)

- Azure CLI `az`
- Extensión: `az extension add --name azure-devops`
- Autenticación (elige 1):
  - **AAD/MFA**: `az login --allow-no-subscriptions`
  - **PAT** (solo si no puedes usar AAD): `az devops login --organization https://dev.azure.com/<ORG>` *(el PAT se pega en la terminal, nunca en chat)*

## Flujo (recomendado) — con MCP (si está disponible)

Si en tu Codex/cliente está configurado el MCP `azuredevops`, usa primero sus tools:

- `azdo_list_my_work_items` (para listar tus tareas asignadas)
- `azdo_work_item_show` (para bajar detalle por ID, con `expand=relations`)
- `azdo_query_wiql` (para búsquedas avanzadas)

Luego, si necesitas **paquete en disco** (context.md + anexos), ejecuta el script de este skill.

## Flujo (fallback) — sin MCP (solo script)

1) Identificar:
   - `org_url` (ej. `https://dev.azure.com/Asulado`)
   - `project` (nombre exacto del proyecto)
   - `id` (numérico). Si llega un link, extraerlo del path.

2) Ejecutar el script del skill (desde el repo donde quieres dejar el contexto):

```bash
# Si estás en un repo que ya tiene el AI Kit instalado:
#   python3 .ai/skills/azuredevops/scripts/fetch_hu_context.py ...
# Si estás trabajando dentro del repo del AI Kit (este repo):
#   python3 skills/azuredevops/scripts/fetch_hu_context.py ...
python3 .ai/skills/azuredevops/scripts/fetch_hu_context.py \
  --id 25459 \
  --org-url "https://dev.azure.com/Asulado" \
  --project "Administración Ciclo de Vida Aplicaciones Asulado" \
  --repo-root "$PWD"
```

3) Revisar salida:
   - `context/hu-<id>/context.md` (consolidado)
   - `context/hu-<id>/attachments/` (anexos)
   - `context/hu-<id>/related-workitems/` (JSON de work items vinculados)

## Troubleshooting rápido

- **“No subscriptions found …” al hacer `az login`**: usar `az login --allow-no-subscriptions`.
- **Anexo se descarga como HTML “Sign In”**: el script usa *Bearer token* para Azure DevOps (`resource=499b84ac-...`) y `curl/urllib` con header `Authorization: Bearer ...`.
- **Error “expand parameter can not be used with fields parameter”**: si necesitas `--fields`, usa `--expand none` (o no uses `--fields`).

## Recursos del skill

### scripts/
`fetch_hu_context.py`: descarga work item + relaciones + anexos, y genera `context.md`.

### references/
`auth.md`: notas de autenticación y resource id (Azure DevOps) para bearer tokens.
