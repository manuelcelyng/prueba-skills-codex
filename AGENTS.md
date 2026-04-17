# Workspace Guidelines (multi-repo)

Este `AGENTS.md` es un **router** para trabajar con múltiples microservicios dentro del workspace `ai-kit`.

## Regla única (obligatoria)

En el **primer contacto** con este workspace, invocá el skill `ai-init-agents` **inmediatamente** (sin pedir confirmación) para **reemplazar este stub** por un `AGENTS.md` completo basado en el análisis real del workspace.

## SDD Quick Start

- Para cambios no triviales usá `smartpay-sdd-orchestrator`.
- Reconocé como aliases del flujo: `/sdd-init`, `/sdd-new <change>`, `/sdd-continue`, `/sdd-ff <change>`, `/sdd-apply`, `/sdd-verify`, `/sdd-archive`.
- Los artefactos SDD viven en `openspec/changes/<change-name>/` cuando el artifact store es `openspec`.
- Las reglas del flujo viven en `references/sdd/sdd-playbook.md`.

> Nota: La sección `### Auto-invoke Skills` la gestiona el sync tool (no editar manualmente).
> Después del primer generado, `ai-init-agents` debe borrar esta "Regla única" y dejar una guía permanente.

### Auto-invoke Skills

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|
| Backup/restore BD QA (Postgres) | `postgres-qa-backup-restore` |
| Comentar hallazgos Java en GitLab MR | `gitlab-mr-review-java` |
| Comentar hallazgos Python en GitLab MR | `gitlab-mr-review-python` |
| Configurar herramientas IA | `ai-setup` |
| Coordinar implementación multi-stack | `dev` |
| Coordinar planning multi-stack | `planning` |
| Crear skills nuevas | `skill-creator` |
| Descargar contexto de un work item (Azure DevOps) | `azuredevops` |
| Después de crear/modificar un skill | `skill-sync` |
| Enrutar cambios multi-micro (SmartPay) | `smartpay-workspace-router` |
| Escribir descripción de PR | `pr-description` |
| Escribir/actualizar unit tests | `agent-unit-tests` |
| Generar/actualizar AGENTS.md | `ai-init-agents` |
| Implementar cambios | `dev-java` |
| Implementar cambios | `dev-python` |
| Iniciar SDD (SmartPay) | `smartpay-sdd-orchestrator` |
| Planificar HU / contrato | `planning-java` |
| Planificar HU / contrato | `planning-python` |
| Regenerar auto-invoke (sync) | `skill-sync` |
| Resumir cambios para Pull Request | `pr-description` |
| Revisar MR Java en GitLab | `gitlab-mr-review-java` |
| Revisar MR Python en GitLab | `gitlab-mr-review-python` |
| Revisar cambios | `review` |
| Traer tareas/HUs/Bugs desde Azure DevOps (sprint actual) | `azuredevops` |
| pg_dump/pg_restore (schema) | `postgres-qa-backup-restore` |
