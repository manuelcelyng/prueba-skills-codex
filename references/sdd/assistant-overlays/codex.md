## SDD Quick Start (Codex)

- Usa `smartpay-sdd-orchestrator` para cambios no triviales dentro de un micro.
- Usa `smartpay-workspace-router` desde el workspace root cuando el cambio toque varios micros.
- Reconoce estos prompts/comandos como aliases de flujo SDD: `/sdd-init`, `/sdd-new <change>`, `/sdd-continue`, `/sdd-ff <change>`, `/sdd-apply`, `/sdd-verify`, `/sdd-archive`.
- Aunque Codex ejecute inline, el flujo sigue siendo delegate-only a nivel lógico: el hilo principal coordina fases, approvals y estado; cada fase sigue su skill `sdd-*`.
- Fuente de verdad del flujo: `./.ai-kit/references/sdd/sdd-playbook.md` + `./.ai-kit/references/sdd/persistence-contract.md`.
