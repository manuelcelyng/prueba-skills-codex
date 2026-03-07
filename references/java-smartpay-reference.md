# Java SmartPay Reference

Referencia consolidada para planning Java en micros SmartPay/ASULADO. Reúne plantilla de contrato, plantilla de plan, ejemplos JSON y checklist para dependencias/ADRs sin duplicar el rulebook normativo de `dev-java`.

## Tabla de contenido
1. Cuándo cargar esta referencia
2. Plantilla de contrato Java
3. Ejemplos JSON base
4. Plantilla de plan de implementación Java
5. Checklist de dependencias y ADRs

## 1. Cuándo cargar esta referencia
- Cuando `planning-java` necesite redactar o revisar `contrato.md` y `plan-implementacion.md`.
- Cuando `review` necesite contrastar ejemplos JSON, expectativas de artefactos o cambios de dependencias/arquitectura.
- Cuando `dev-java` necesite validar que el contrato/plan cubren todos los casos antes de implementar.

## 2. Plantilla de contrato Java

### 2.1 Contexto
- HU / objetivo.
- Alcance.
- Fuera de alcance.
- Supuestos/dependencias.

### 2.2 Endpoint o interfaz
Por endpoint/interfaz:
- método + path;
- headers requeridos (incluye `traceId` si aplica);
- query params / path vars;
- request body (schema + validaciones);
- reglas funcionales o precondiciones.

### 2.3 Responses
Por código HTTP o respuesta funcional:
- `codigoRespuesta` (`ErrorCode`/`SuccessCode` si aplica);
- `mensaje` en español;
- ejemplo JSON completo;
- notas de paginación/correlación si aplican.

### 2.4 Errores
- catálogo de `ErrorCode` a usar (prefijo del micro);
- tabla: `ErrorCode` → HTTP → mensaje base → condición de disparo.

### 2.5 Observabilidad
- logs de inicio/fin y errores (sin PII);
- campos mínimos de correlación (`traceId`, `idTrazabilidad` o equivalente);
- métricas/eventos si el micro las exige.

### 2.6 Criterios de aceptación
- casos felices;
- casos de error (validación, not found, externo, interno);
- bordes (paginación, nulos, límites, duplicados, idempotencia).

## 3. Ejemplos JSON base

### 3.1 Request paginado
```json
{"pagina":1,"tamano":10,"filtros":{"estado":"APROBADO"}}
```

### 3.2 Response éxito
```json
{
  "resultado": true,
  "datos": {
    "paginacion": {
      "pagina": 1,
      "tamano": 10,
      "filtros": {"estado": "APROBADO"},
      "totalRegistros": 100,
      "totalPaginas": 10
    },
    "registros": [
      {"idLote": 1, "estado": "APROBADO"}
    ]
  },
  "errores": null,
  "codigoRespuesta": "00",
  "mensaje": "Consulta exitosa",
  "fechaHora": "2025-11-08T12:00:00",
  "idTrazabilidad": "abc-123"
}
```

### 3.3 Response error
```json
{
  "resultado": false,
  "datos": null,
  "errores": [
    {"campo": "pagina", "mensaje": "La página debe ser mayor que cero"}
  ],
  "codigoRespuesta": "VAL-001",
  "mensaje": "Error de validación",
  "fechaHora": "2025-11-08T12:05:00",
  "idTrazabilidad": "def-456"
}
```

### 3.4 Reglas mínimas para ejemplos
1. Incluir correlación (`traceId`, `idTrazabilidad` o el campo estándar del micro).
2. `errores` es lista de `{campo, mensaje}`.
3. En error: `datos = null`. En éxito: `errores = null`.
4. No omitir `codigoRespuesta` ni `mensaje`.

## 4. Plantilla de plan de implementación Java

### 4.1 Scope técnico
- componentes/módulos afectados;
- cambios por capa (Domain / UseCase / Infrastructure / Entry Points).

### 4.2 Modelo y puertos
- nuevos modelos o cambios;
- puertos nuevos o extendidos (firma + intención).

### 4.3 Persistencia (SQL / R2DBC)
- estrategia elegida: derived query / `@Query` / `DatabaseClient`-`SQLProvider`;
- borrador SQL con **named params** si aplica;
- parámetros esperados (map);
- joins/índices/riesgos de performance si impactan el cambio.

### 4.4 Contrato y errores
- cambios de DTOs;
- códigos de respuesta y ejemplos;
- `ErrorCode` a crear/ajustar;
- logs y constantes a centralizar.

### 4.5 Tests
- UseCase: escenarios + mocks;
- SQL Provider: estructura del query + params;
- Adapter: mapeos y manejo de errores;
- Handler/Router: contrato (status/body);
- evidencia esperada (`./gradlew test`, slices, build, etc.).

### 4.6 Riesgos y validación
- riesgos (performance, compatibilidad, seguridad);
- comandos de validación;
- preguntas abiertas o dependencias externas.

## 5. Checklist de dependencias y ADRs

### 5.1 Nueva dependencia Java
- [ ] Hay una necesidad concreta y justificada.
- [ ] No existe ya una alternativa equivalente en el proyecto.
- [ ] Es compatible con Java 21, WebFlux y R2DBC.
- [ ] Se revisaron CVEs/conflictos transitivos.
- [ ] El impacto operativo/performance es aceptable.
- [ ] Si es una decisión estratégica, quedó documentada en ADR o artefacto equivalente.

### 5.2 Cuándo exigir ADR
- Se introduce tecnología nueva (librería/framework).
- Se cambia un patrón base (arquitectura, modelado, persistencia, mensajería).
- Se toma una decisión con trade-offs relevantes (seguridad, performance, costo, operatividad).

### 5.3 Formato recomendado de ADR
- ID: `ADR-XXX`
- Fecha: `YYYY-MM-DD`
- Título
- Contexto / problema
- Decisión
- Alternativas consideradas
- Consecuencias (positivas/negativas)
- Estado: `Propuesto | Aprobado | Rechazado | Obsoleto`

