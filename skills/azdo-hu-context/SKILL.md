---
name: azdo-hu-context
description: >-
  Descarga y consolida el contexto de un work item de Azure DevOps Boards (User
  Story/HU/Task/Bug) a partir de un link o ID. Úsalo cuando el usuario pida
  "trae/baja la HU", "descarga la tarea", "trae anexos" o "arma un context", o
  necesites: (1) bajar el work item en JSON, (2) descargar anexos (AttachedFile),
  (3) traer work items relacionados (parent/child/related), y (4) generar un
  `context.md` en el repo (por defecto `context/hu-{id}/context.md`).
---

# azdo-hu-context

## Objetivo

Automatizar la descarga de una HU/tarea de Azure DevOps (incluyendo anexos y work items relacionados) y dejar un “paquete de contexto” en el repo para implementación/QA.

## Pre-requisitos (una vez por máquina)

- Azure CLI `az`
- Extensión: `az extension add --name azure-devops`
- Autenticación (elige 1):
  - **AAD/MFA**: `az login --allow-no-subscriptions`
  - **PAT** (solo si no puedes usar AAD): `az devops login --organization https://dev.azure.com/<ORG>` *(el PAT se pega en la terminal, nunca en chat)*

## Flujo (recomendado)

1) Identificar:
   - `org_url` (ej. `https://dev.azure.com/Asulado`)
   - `project` (nombre exacto del proyecto)
   - `id` (numérico). Si llega un link, extraerlo del path.

2) Ejecutar el script del skill (desde el repo donde quieres dejar el contexto):

```bash
# Si estás en un repo que ya tiene el AI Kit instalado:
#   python3 .ai/skills/azdo-hu-context/scripts/fetch_hu_context.py ...
# Si estás trabajando dentro del repo del AI Kit (este repo):
#   python3 skills/azdo-hu-context/scripts/fetch_hu_context.py ...
python3 .ai/skills/azdo-hu-context/scripts/fetch_hu_context.py \
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
