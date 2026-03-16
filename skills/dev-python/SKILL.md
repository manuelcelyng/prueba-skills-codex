---
name: dev-python
description: >
  Implementa cambios en servicios Python (lambda-* / FastAPI) siguiendo el estándar canónico de SmartPay/ASULADO.
  Trigger: Cuando el usuario pida implementar/fix/refactor o agregar endpoints/tests en un servicio Python.
license: Internal
metadata:
  author: pragma-smartpay
  version: "0.3"
  scope: [root]
  auto_invoke:
    - "Implementar cambios"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Desarrollo Python (canónico)

Este skill es la **fuente normativa** para implementación Python del kit. `review` debe auditar cualquier cambio Python contra este baseline y contra las reglas locales del repo.

## Shared Operating Model

Antes de codificar, leer `.ai-kit/references/delivery-flow.md` para precedencia, contexto mínimo, gates HU/SDD, write locations y evidencia de cierre.

## Mandatory Reroute

Detén la implementación y redirige cuando aplique:
- si el cambio es no trivial y faltan `proposal/spec/design/tasks` o `contrato + plan`, usar `smartpay-sdd-orchestrator` o `planning-python`;
- si el cambio toca varios micros o mezcla stacks, coordinar con `dev` y/o `smartpay-workspace-router`;
- si el repo tiene reglas locales más estrictas, esas reglas ganan.

## Implementation Workflow

1. Confirmar alcance, interfaz afectada, runtime y dependencias externas.
2. Implementar por lotes pequeños alineados con `tasks.md` o `plan-implementacion.md`.
3. Actualizar pruebas en paralelo.
4. Autoverificar el batch contra las secciones 1-8 de este skill antes de seguir.
5. Ejecutar pruebas reales (`pytest`, `black`, `isort`, `mypy`, `ruff` o las del repo) y reportar evidencia.

## Canonical Python Rulebook

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
- En `configsecret`, manifests y configuración operativa, todo `path`, `key`, `url`, endpoint o equivalente debe salir de env vars/config centralizada; además, el nombre de la variable debe ir en inglés y reflejar el dominio/capacidad donde se usa.
- Si cambias runtime, dependencias o variables requeridas, actualiza también `pyproject.toml`, `template.yaml`, manifests o documentación operativa correspondiente.
- No acoples endpoints/URLs externas directo en el código si el repo ya usa settings/config centralizada.

### 5) Persistencia y SQL
- Si el servicio usa SQL, documenta consultas y usa parámetros nombrados o mecanismos seguros equivalentes.
- No concatenes input del usuario en queries ni paths de acceso a datos.
- Mantén el mecanismo de persistencia coherente con el repo (ORM, client, repository, raw SQL, etc.).

### 6) Estilo, tipado y mantenibilidad
- Código y nombres internos en inglés salvo que el repo use otra convención.
- Mantén type hints en funciones públicas y capas de aplicación/dominio cuando el servicio ya lo haga.
- Respeta formato/herramientas del repo: `black`, `isort`, `mypy`, `ruff`, etc.
- Usa la versión de Python definida por el servicio.

### 7) Testing mínimo obligatorio
- Añade o actualiza tests `pytest` para happy path y al menos un error path relevante.
- Replica la estructura del código bajo `tests/` cuando el repo siga ese patrón.
- Usa fixtures/builders reutilizables; evita hardcodear datos de negocio inestables.
- Si hay cobertura objetivo del repo, respétala; como baseline del kit apunta a >80% cuando aplique.

### 8) Cleanup y calidad
- Elimina código muerto, imports no usados y helpers temporales.
- No dejes comentarios obsoletos ni configuraciones duplicadas.
- Evita funciones gigantes, duplicación y lógica transversal copiada entre handlers.
- Si la solución introduce decisiones operativas o dependencias relevantes, deja el rastro documental que exija el repo.

## Done Criteria

Antes de cerrar el cambio confirma:
- contrato/specs siguen alineados con la implementación;
- configuración, runtime y documentación quedaron consistentes;
- pruebas y checks reales fueron ejecutados;
- reportas archivos tocados, pruebas ejecutadas y cualquier desviación del plan.

## References
- `.ai-kit/references/delivery-flow.md`
- `.ai-kit/references/python-smartpay-reference.md`
- `.ai-kit/references/sdd/sdd-playbook.md`
