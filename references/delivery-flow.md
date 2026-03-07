# Delivery Flow Reference (ASULADO)

Guía compartida para `planning-*`, `dev-*` y `review`. Úsala para evitar repetir el mismo baseline operativo en cada skill.

## 1. Source of truth (precedencia)
1. `AGENTS.md` del repo/workspace y `context/` local.
2. Skills overlay del micro (`./skills/*`) cuando existan.
3. Artefactos funcionales aprobados del cambio: `openspec/changes/<change>/...` o `context/hu/<HU_ID>/...`.
4. Skill canónico del stack (`dev-java` o `dev-python`).
5. Esta referencia y los playbooks/templates del kit.

## 2. Contexto mínimo a cargar
1. `AGENTS.md` + contexto local relevante del repo.
2. Manifests del stack (`build.gradle*`, `pom.xml`, `pyproject.toml`, `requirements*.txt`, `template.yaml`, etc.).
3. HU/contrato/plan o artefactos SDD (`proposal/spec/design/tasks`).
4. Skills locales relevantes del micro (error codes, SQL providers, catálogos, etc.).
5. Código y tests similares en la zona afectada.
6. Para review: diff, archivos tocados y evidencia de pruebas/build.

## 3. Gate obligatorio para cambios no triviales
Trata el cambio como **no trivial** si toca cualquiera de estos frentes:
- 2 o más capas/componentes;
- contrato o interfaz;
- SQL/persistencia;
- reglas de negocio;
- varios archivos/módulos;
- más de un microservicio.

No implementes ni revises como “listo” un cambio no trivial si falta alguno de estos caminos:
- **SDD**: `proposal/spec/design/tasks` suficientemente definidos.
- **HU tradicional**: `contrato.md` + `plan-implementacion.md` suficientemente definidos.

Si faltan esos artefactos:
- usar `smartpay-sdd-orchestrator` para iniciar/completar el flujo SDD, o
- usar `planning-java` / `planning-python` para completar contrato y plan.

## 4. Deliverables por fase

### Planning
- contexto, alcance, supuestos y fuera de alcance;
- contrato/interfaz con códigos y ejemplos suficientes;
- plan técnico por capas/componentes;
- SQL borrador o justificación de ausencia;
- checklist de “listo para implementar”.

### Desarrollo
- implementación en batches pequeños alineados con el plan;
- tests actualizados en paralelo;
- contrato, errores, logs, constantes y manifests alineados con el cambio;
- cleanup antes de cerrar.

### Review
- validación de proceso;
- auditoría técnica contra el skill canónico del stack;
- validación de evidencia real;
- hallazgos priorizados.

## 5. Write locations estándar
- Contrato HU: `context/hu/<HU_ID>/contrato.md`
- Plan HU: `context/hu/<HU_ID>/plan-implementacion.md`
- Cambio SDD: `openspec/changes/<change-name>/`

Si el repo ya tiene archivos equivalentes, actualiza esos en lugar de duplicar estructura.

## 6. Evidencia mínima antes de cerrar
- comandos reales ejecutados (`./gradlew test`, `pytest`, build, linters o equivalentes);
- archivos tocados y alcance final;
- desviaciones respecto al plan/spec y por qué;
- razones explícitas si algún test/check no pudo correrse.

## 7. Reglas transversales
- No gestionar git, ramas o PRs salvo petición explícita del usuario.
- No inventar contratos, error codes ni estrategias de persistencia sin dejar artefactos actualizados.
- Si agregas dependencias o decisiones con trade-offs relevantes, deja rastro documental (ADR, plan o artefacto requerido por el repo).

