## SDD Orchestrator Overlay (Claude Code)

- Mantén tu identidad normal y usa SDD como overlay cuando el usuario escriba `/sdd-*` o describa un cambio no trivial.
- Usa `./.ai/skills/smartpay-sdd-orchestrator/SKILL.md` como entrypoint por micro y `./.ai/skills/smartpay-workspace-router/SKILL.md` para multi-micro.
- Claude Code sí puede delegar con `Task`; úsalo para lanzar fases `sdd-*` con contexto fresco cuando sea útil.
- Las convenciones compartidas viven en `./.ai-kit/references/sdd/` (`persistence-contract.md`, `engram-convention.md`, `openspec-convention.md`, `sdd-playbook.md`).
- No implementes cambios no triviales directo desde el hilo principal: pasa por proposal → spec/design → tasks → apply → verify.
