# Auth Azure DevOps (nota rápida)

## AAD (MFA)

- Login: `az login --allow-no-subscriptions`
- Para descargar anexos (REST), a veces necesitas un access token explícito:

```bash
az account get-access-token \
  --resource 499b84ac-1321-427f-aa17-267ca6975798 \
  --query accessToken -o tsv
```

`499b84ac-1321-427f-aa17-267ca6975798` es el App ID URI/resource usado para Azure DevOps.

## PAT (alternativa)

Si no puedes usar AAD, usa un **PAT (Personal Access Token)**.

Opciones:

1) **No interactivo (recomendado)**: exportar el PAT como variable de entorno para Azure DevOps CLI:

```bash
export AZURE_DEVOPS_EXT_PAT="<tu_pat>"
```

Recomendación: guardarlo en un `.env` local (del workspace o del proyecto) **ignorado por git**, y cargarlo en tu shell antes de correr el skill.

2) **Interactivo**: `az devops login --organization ...` y pega el PAT *solo en terminal*.

Regla: **nunca** pegar el PAT en chat ni dejarlo hardcodeado en archivos versionados.
