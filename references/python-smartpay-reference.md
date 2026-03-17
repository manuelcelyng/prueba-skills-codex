# Python SmartPay Reference

Referencia consolidada para planning Python en servicios FastAPI, Lambdas y ETLs de SmartPay/ASULADO. Reúne plantilla de contrato y plan para reducir ruido entre referencias separadas.

## Tabla de contenido
1. Cuándo cargar esta referencia
2. Plantilla de contrato Python
3. Plantilla de plan de implementación Python

## 1. Cuándo cargar esta referencia
- Cuando `planning-python` necesite redactar o revisar `contrato.md` y `plan-implementacion.md`.
- Cuando `review` necesite contrastar expectativas de artefactos Python.
- Cuando `dev-python` necesite verificar que el contrato/plan cubren runtime, configuración y pruebas antes de implementar.
- Esta referencia **no reemplaza** el baseline técnico: las reglas normativas viven en `python-smartpay-rulebook.md`.

## 2. Plantilla de contrato Python

### 2.1 Contexto
- HU / objetivo.
- Alcance.
- Fuera de alcance.
- Supuestos/dependencias.

### 2.2 Tipo de interfaz
Elegir uno:
- HTTP (FastAPI)
- Evento (Lambda/SQS/SNS)
- Batch/ETL

### 2.3 Contrato

#### HTTP
- método + path;
- headers requeridos (incluye `trace_id`/correlación si aplica);
- query params / path vars;
- request body (schema + validaciones);
- responses por HTTP (código + `codigoRespuesta` + mensaje ES + ejemplo JSON).

#### Evento
- evento/payload de entrada (schema, campos obligatorios);
- salida esperada (DB/SQS/HTTP) y estados lógicos;
- errores esperados y mapeos si aplican.

#### Batch/ETL
- fuente(s) de entrada;
- transformaciones esperadas;
- salida(s) y controles de consistencia;
- manejo de errores y reintentos.

### 2.4 Observabilidad
- logging con `trace_id` o correlación equivalente (sin PII);
- métricas/eventos si aplica;
- alarmas o trazabilidad operativa relevante.

### 2.5 Criterios de aceptación
- casos felices;
- casos de error (validación, not found, externo, interno);
- bordes (payload vacío, duplicados, timeouts, idempotencia, etc.).

## 3. Plantilla de plan de implementación Python

### 3.1 Scope técnico
- componentes/módulos afectados;
- cambios por capas (si aplica): `domain/application/infrastructure` o `extract/transform/load`.

### 3.2 Datos e integración
- contratos consumidos/producidos;
- persistencia (SQL o equivalente) + named params si hay SQL;
- variables de entorno, secretos y configuración.

### 3.3 Manejo de errores
- excepciones y mapeos a respuesta/estado;
- estrategia de retries/timeouts si aplica;
- impacto en observabilidad.

### 3.4 Runtime y manifests
- cambios en `pyproject.toml`, `requirements*.txt`, `template.yaml`, SAM/K8s o manifests;
- compatibilidad con la versión de Python del servicio.

### 3.5 Tests
- `pytest`: escenarios (happy + errores);
- fixtures/mocks y cobertura objetivo;
- comandos de validación (`pytest`, `ruff`, `black`, `isort`, `mypy`, etc.).

### 3.6 Riesgos y validación
- riesgos (runtime, deps, perf, seguridad);
- preguntas abiertas o dependencias externas.
