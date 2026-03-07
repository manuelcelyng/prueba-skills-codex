---
name: dev-python
description: >
  Implementa cambios en servicios Python (lambda-* / FastAPI) siguiendo el estándar canónico de SmartPay/ASULADO.
  Trigger: Cuando el usuario pida implementar/fix/refactor o agregar endpoints/tests en un servicio Python.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.2"
  scope: [root]
  auto_invoke:
    - "Implementar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

## Purpose

Este skill es la **fuente canónica** para implementación Python en el kit. Define cómo debe escribir código la IA en Lambdas, ETLs y servicios FastAPI del ecosistema SmartPay/ASULADO.

## Source of truth (precedencia)

1. `AGENTS.md` del repo y contexto local del servicio.
2. Skills overlay del micro (`./skills/*`) cuando apliquen.
3. Artefactos funcionales aprobados: `openspec/changes/<change>/...` o `context/hu/<HU_ID>/...`.
4. Este skill.

## Required Context (load order)

1. Leer `AGENTS.md`, `README.md` y `context/` relevante del servicio.
2. Si existe `openspec/changes/<change-name>/`, leer `proposal.md`, specs, `design.md` y `tasks.md`.
3. Si no existe `openspec/`, leer HU, contrato y plan de implementación disponibles.
4. Leer `pyproject.toml`, `requirements*.txt`, `template.yaml` o manifests equivalentes.
5. Revisar código y tests similares en el servicio antes de crear archivos nuevos.

## Mandatory Gate

No implementes cambios no triviales sin uno de estos dos insumos:

- **SDD activo**: `proposal/spec/design/tasks` definidos en `openspec/changes/<change-name>/`.
- **HU tradicional**: contrato + plan de implementación aprobados en `context/hu/<HU_ID>/`.

Si faltan esos artefactos:
- usar `smartpay-sdd-orchestrator` si el usuario quiere flujo SDD completo, o
- usar `planning-python` si el trabajo viene por HU/contrato.

## Implementation Workflow

1. Confirmar alcance, interfaz afectada y dependencias externas.
2. Implementar por lotes pequeños alineados con `tasks.md` o el plan de la HU.
3. Actualizar pruebas en paralelo.
4. Validar contrato, logging, configuración, runtime y cleanup.
5. Ejecutar pruebas reales (`pytest`, `black`, `isort`, `mypy` o las del repo) y reportar evidencia.

## Reglas Python no negociables

### 1) Arquitectura y estructura
- Respeta la arquitectura definida por el servicio; si el repo separa `domain/application/infrastructure`, no mezcles capas.
- En Lambdas ETL conserva separación `extract/`, `transform/`, `load/`, `utils/`, `config/` y entry point en `src/lambda_handler.py` cuando ese patrón exista.
- En FastAPI, mantén routers delgados y mueve negocio a servicios/casos de uso.
- Evita side-effects globales y lógica en módulos importados al cargar la app.

### 2) Contrato y validación
- Toda interfaz HTTP/evento debe mantenerse alineada con el contrato aprobado.
- En HTTP usa modelos/tipos del framework (por ejemplo Pydantic) para validación y serialización; evita validaciones manuales dispersas si el framework ya las resuelve.
- En eventos/Lambdas documenta payload de entrada, efectos esperados y errores funcionales.
- Mensajes visibles al usuario en español si el servicio ya sigue esa convención.

### 3) Logging, trazabilidad y errores
- Logging estructurado con `trace_id` o helper equivalente del repo.
- No loguear secretos ni PII.
- Maneja errores de forma consistente con la arquitectura del servicio; no ocultes excepciones ni devuelvas errores ambiguos.
- Si el servicio ya tiene catálogo/error mapping, úsalo; no inventes respuestas paralelas.

### 4) Configuración y seguridad
- Secretos y configuraciones sensibles por env vars/SSM/Parameter Store; nunca hardcode.
- Si cambias runtime, dependencias o variables requeridas, actualiza también `pyproject.toml`, `template.yaml`, manifests o documentación operativa correspondiente.
- No acoples endpoints/URLs externas directo en el código si el repo ya usa settings/config centralizada.

### 5) Persistencia y SQL
- Si el servicio usa SQL, documenta consultas y usa parámetros nombrados o mecanismos seguros equivalentes.
- No concatenes input del usuario en queries ni paths de acceso a datos.
- Mantén el mecanismo de persistencia coherente con el repo (ORM, client, repository, raw SQL, etc.).

### 6) Estilo y tipado
- Código y nombres internos en inglés salvo que el repo use otra convención.
- Mantén type hints en funciones públicas y capas de aplicación/dominio cuando el servicio ya lo haga.
- Respeta formato/herramientas del repo: `black`, `isort`, `mypy`, `ruff`, etc.
- Usa la versión de Python definida por el servicio.

### 7) Testing obligatorio
- Añade/actualiza tests `pytest` para happy path y al menos un error path relevante.
- Replica la estructura del código bajo `tests/` cuando el repo siga ese patrón.
- Usa fixtures/builders reutilizables; evita hardcodear datos de negocio inestables.
- Si hay cobertura objetivo del repo, respétala; como baseline del kit apunta a >80% cuando aplique.

### 8) Cleanup y calidad
- Elimina código muerto, imports no usados y helpers temporales.
- No dejes comentarios obsoletos ni configuraciones duplicadas.
- Evita funciones gigantes, duplicación y lógica transversal copiada entre handlers.

## Done Criteria

Antes de cerrar el cambio confirma:
- contrato/specs siguen alineados con la implementación;
- configuración/runtime/documentación quedaron consistentes;
- pruebas y checks reales fueron ejecutados;
- reportas archivos tocados, pruebas ejecutadas y cualquier desviación del plan.

## Optional References

- `.ai-kit/references/contract-template-python.md`
- `.ai-kit/references/plan-template-python.md`
- `.ai-kit/references/sdd/sdd-playbook.md`
