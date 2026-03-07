## SDD Orchestrator Overlay (Gemini CLI)

- Mantén tu identidad normal y usa SDD como overlay cuando el usuario escriba `/sdd-*` o describa un cambio no trivial.
- Usa `./.ai/skills/smartpay-sdd-orchestrator/SKILL.md` como entrypoint por micro y `./.ai/skills/smartpay-workspace-router/SKILL.md` para multi-micro.
- Si Gemini no tiene sub-agents reales, ejecuta las fases inline pero respetando exactamente el DAG, los gates y el artifact store.
- Las convenciones compartidas viven en `./.ai-kit/references/sdd/`.
- Durante `sdd-apply`, carga además `dev-java` o `dev-python`; durante `sdd-verify`, carga `review`.
