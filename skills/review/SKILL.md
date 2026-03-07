---
name: review
description: >
  Revisa cambios y valida cumplimiento de reglas, contrato/plan o artefactos SDD, usando dev-java/dev-python como estándar canónico.
  Trigger: Cuando el usuario pida code review, auditoría técnica o validación de HU/checklists.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.4"
  scope: [root]
  auto_invoke:
    - "Revisar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Review (canónico)

Este skill es la **fuente normativa de auditoría** del kit. Su trabajo es validar proceso, cumplimiento técnico y evidencia real contra `dev-java`, `dev-python`, el contrato y los artefactos HU/SDD.

## Shared Operating Model

Leer `.ai-kit/references/delivery-flow.md` antes de revisar. Ese documento define precedencia, contexto mínimo, gates y evidencia requerida. `review` no debe aprobar como “listo” un cambio que incumpla ese baseline.

## Normative Baseline

- Para Java, el baseline obligatorio es `dev-java` + `.ai-kit/references/java-smartpay-rulebook.md`.
- Para Python, el baseline obligatorio es `dev-python`.
- Usa `.ai-kit/references/java-smartpay-reference.md` o `.ai-kit/references/python-smartpay-reference.md` solo cuando necesites contrastar contrato, ejemplos, plan, dependencias o ADRs.

## Review Workflow

1. Validar primero el **proceso**: artefactos suficientes, alineación con HU/SDD y cambios documentales requeridos.
2. Revisar después el **cumplimiento técnico** por stack contra el skill canónico de implementación.
3. Verificar por último la **evidencia real**: pruebas, build, cobertura o comandos corridos.
4. Emitir hallazgos ordenados por severidad, con referencias concretas a archivo/línea cuando aplique.

## Output (mandatory)

1. **Hallazgos** primero, ordenados por severidad.
2. Para hallazgos puntuales usar `::code-comment{...}` con archivo y líneas.
3. Luego listar **preguntas / supuestos / faltantes de contexto**.
4. Cerrar con un **resumen corto** del estado general.

## Mandatory Process Checks

Reporta hallazgo de proceso cuando aplique:
- cambio no trivial sin `proposal/spec/design/tasks` ni `contrato + plan`;
- implementación que contradice el contrato o specs aprobados;
- cambio que introduce error codes, dependencias o decisiones sin actualizar la evidencia documental requerida;
- cambio “listo para merge” sin evidencia real de tests/build.

## Java Audit Lens (audit against `dev-java` + rulebook)

### `J-ARC-*` y `J-NAM-*`
- Verifica hexagonal/clean, ownership de capas, puertos `Port` y naming consistente.
- Señala cualquier `Gateway`, `Repository` de dominio o `UseCase` nombrado como verbo genérico (`Manage`, `Create`, `Process`, `Handle`, `execute`).
- Señala helpers, utilitarios o `*TestData` que debían ser `@UtilityClass` y quedaron como clases instanciables.

### `J-REA-*`
- Señala `.block()`, `Thread.sleep`, JDBC, `subscribe()` manual no justificado, materialización innecesaria o composición reactiva defectuosa.

### `J-API-*`
- Verifica que success y error responses salgan por builders auditables, que propaguen `traceId` y que las validaciones respondan en español con campo funcional.

### `J-MAP-*` y `J-SQL-*`
- Verifica mappers MapStruct, ausencia de builders cross-layer inline en el flujo, estrategia SQL adecuada, named params, aliases legibles y separación de row mapping.

### `J-ERR-*`
- Señala ausencia de `BusinessException` + `ErrorCode`, logs fuera de convención, PII o literales técnicos sin centralizar.

### `J-TST-*` y `J-QLT-*`
- Verifica TDD implícito en el cambio, slices mínimas, naming `shouldXWhenY`, `*TestData`, ausencia de code smells y comentarios innecesarios/código comentado.

### `J-DOC-*`
- Verifica que contrato, catálogo de errores y ADRs/artefactos asociados se hayan actualizado cuando el cambio lo requiere.

## Python Audit Lens (audit against `dev-python`)

### 1) Arquitectura y contrato
- Aplica las secciones 1 y 2 de `dev-python`.
- Señala lógica de negocio en handlers/routers o contratos que no coinciden con lo aprobado.

### 2) Observabilidad, configuración y seguridad
- Aplica las secciones 3 y 4 de `dev-python`.
- Señala logging deficiente, secretos hardcodeados, runtime/configuración desalineada o manifests sin actualizar.

### 3) Persistencia, estilo y calidad
- Aplica las secciones 5, 6 y 8 de `dev-python`.
- Señala acceso a datos inseguro, falta de tipado/formatters del repo, side-effects globales, código muerto o duplicación.

### 4) Testing
- Aplica la sección 7 de `dev-python`.
- Verifica que existan tests `pytest` suficientes y evidencia real de ejecución.

## Done Criteria

Un review está completo cuando:
- el cambio fue contrastado contra contrato/specs y reglas canónicas del stack;
- los hallazgos tienen archivo, línea y severidad suficientes para actuar;
- quedó claro qué falta para aprobar o por qué puede aprobarse.
