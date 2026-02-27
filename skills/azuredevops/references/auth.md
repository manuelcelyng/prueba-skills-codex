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

Si no puedes usar AAD, usa `az devops login --organization ...` y pega el PAT *solo en terminal*.
