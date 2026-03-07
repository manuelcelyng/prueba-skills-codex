## SDD Orchestrator Overlay (GitHub Copilot)

- Usa SDD como overlay cuando el usuario escriba `/sdd-*` o plantee una feature/refactor no trivial.
- Entry points: `./.ai/skills/smartpay-sdd-orchestrator/SKILL.md` (micro) y `./.ai/skills/smartpay-workspace-router/SKILL.md` (workspace).
- Si no hay sub-agents frescos, corre las fases inline pero conserva gates, estado y artefactos.
- Sigue `./.ai-kit/references/sdd/sdd-playbook.md` y `./.ai-kit/references/sdd/persistence-contract.md` como fuente del flujo.
- No saltes a código si no existen artefactos suficientes de proposal/spec/design/tasks.
