# GitLab MR Review Commenting Guide

Guía compartida para skills que revisan Merge Requests directamente en GitLab.

## Objetivo

Dejar comentarios **accionables, objetivos, humanos y en español** sobre incumplimientos reales de reglas del kit, con contexto suficiente para que el autor pueda corregir sin ambigüedad.

## Reglas obligatorias para comentar

1. **Un hallazgo por comentario**
   - No mezclar varias reglas en el mismo hilo.
   - Si un patrón se repite, comentar un caso representativo y mencionar que el problema aparece en más lugares.

2. **Solo comentar hallazgos accionables**
   - Evitar felicitaciones, comentarios de estilo subjetivo o nits sin impacto real.
   - No comentar código generado, snapshots o artefactos sin valor de revisión, salvo que rompan una regla canónica.

3. **Comentar sobre la línea exacta**
   - Preferir comentario inline/discussion en la línea más cercana al problema.
   - Si el hallazgo abarca varias líneas, escoger la línea raíz del problema.

4. **Referenciar la regla**
   - Java: usar IDs oficiales del rulebook (`J-REA-006`, `J-MAP-005`, etc.).
   - Python: usar IDs estables del skill (`PY-ARC`, `PY-CONFIG`, `PY-TEST`, etc.).

5. **Explicar impacto y corrección**
   - El comentario debe dejar claro:
     - qué está mal,
     - por qué importa,
     - qué debería hacerse,
     - y un ejemplo corto de corrección.

6. **No especular**
   - Si falta contexto y no puedes afirmar el incumplimiento con confianza, formula el comentario como duda concreta o no comentes.

7. **Mantener un tono humano y amable**
   - Redactar de forma profesional pero cercana.
   - Evitar tono frío, agresivo, sarcástico o acusatorio.
   - Se permite abrir con frases cortas como `Ojo aquí`, `Aquí conviene ajustar`, `Pequeño detalle importante`, siempre que el comentario siga siendo técnico y directo.

8. **Complementar comentarios existentes cuando aporte valor**
   - Antes de comentar, revisar si ya existe una discusión sobre el mismo punto.
   - Si el comentario existente ya cubre bien el hallazgo, no duplicar.
   - Si el comentario existente va bien encaminado pero quedó corto, ambiguo o sin regla/impacto/sugerencia, complementar en el mismo hilo.
   - Preferir responder en la discusión existente antes que abrir un comentario nuevo sobre el mismo problema.

## Estructura recomendada según el tipo de comentario

### 1) Comentario inline sobre el diff — formato corto

Úsalo cuando GitLab permita anclar el hallazgo a una línea del diff actual.

- Título con severidad + regla/tag.
- 1 párrafo corto explicando el problema.
- 1 línea de impacto.
- 1 línea de sugerencia.
- **Ejemplo solo si realmente acelera la corrección**.

Base sugerida:

```md
[P<n>][<RULE_ID>] <título corto del hallazgo>

Aquí conviene ajustar `<RULE_ID>`, porque <explicación concreta y verificable>.
Impacto: <riesgo funcional/técnico breve>.
Sugerencia: <cambio esperado en una frase>.
```

### 2) Nota general del MR — formato medio

Úsalo cuando el hallazgo **no pueda quedar inline** porque la línea ya no hace parte del diff visible o porque GitLab no permita anclarla.

- Aclara brevemente que es una nota general del MR.
- Incluye archivo y línea.
- 1 párrafo corto explicando el problema.
- 1 línea de impacto.
- 1 línea de sugerencia.
- **Ejemplo solo si realmente reduce ambigüedad**.

Base sugerida:

```md
Nota general del MR: esta observación no quedó inline porque la línea no hace parte del diff actual.

Archivo: `<path/al/archivo>`
Línea: `<n>`

[P<n>][<RULE_ID>] <título corto del hallazgo>

Aquí conviene ajustar `<RULE_ID>`, porque <explicación concreta y verificable>.
Impacto: <riesgo funcional/técnico breve>.
Sugerencia: <cambio esperado en una frase>.
```

## Formato obligatorio del comentario

Usa como default:

- **formato corto** para comentarios inline,
- **formato medio** para notas generales del MR.
- **complemento corto/medio** cuando ya exista un comentario correcto pero incompleto en ese mismo punto.

No alargar el comentario si el mismo hallazgo ya queda claro con menos texto.

Si incluyes ejemplo:
- que sea corto,
- que apunte a la corrección exacta,
- y que no convierta el comentario en una mini solución completa si no hace falta.

Si complementas un comentario existente:
- agrega lo que falta (regla, impacto o sugerencia),
- evita repetir literalmente lo que ya dijo el hilo,
- mantén el tono cordial y colaborativo.

Usa este formato base:

```md
[P<n>][<RULE_ID>] <título corto del hallazgo>

Aquí se está incumpliendo `<RULE_ID>` porque <explicación concreta y verificable>.
Impacto: <riesgo funcional/técnico breve>.
Sugerencia: <cambio esperado en una frase>.

Ejemplo sugerido:
```<lang>
<snippet corto>
```
```

## Severidad sugerida

- `P1`: bug real, riesgo de regresión, incumplimiento fuerte de arquitectura/flujo, seguridad o error funcional.
- `P2`: diseño/contrato/testing/observabilidad que probablemente debe corregirse antes de merge.
- `P3`: mejora importante pero no bloqueante; usar con moderación.

## Ejemplo Java

```md
[P1][J-REA-006] Excepción fuera del flujo reactivo

Aquí conviene ajustar `J-REA-006`, porque la serialización JSON se está ejecutando en un `try/catch` que lanza la excepción antes de retornar el `Mono`.
Impacto: el error sale del pipeline y ya no puede ser gestionado por operadores reactivos posteriores.
Sugerencia: encapsula la serialización con `Mono.fromCallable(...)` y mapea la excepción con `onErrorMap(...)`.

Ejemplo sugerido:
```java
return Mono.fromCallable(() -> objectMapper.writeValueAsString(dto))
    .onErrorMap(JsonProcessingException.class,
        ex -> new BusinessException(ErrorCode.ERROR_PUBLISHING_MESSAGE, traceId))
    .flatMap(payload -> sqsProducer.produceMessage(payload, properties));
```

## Ejemplo de nota general del MR

```md
Nota general del MR: esta observación no quedó inline porque la línea no hace parte del diff actual.

Archivo: `domain/usecase/src/main/java/.../ProcessDailyCxpCancellationUseCase.java`
Línea: `179`

[P2][J-REA-006] La construcción del request SAP quedó fuera del pipeline reactivo

Aquí conviene mover `requestBuilder.buildRequest(...)` dentro del flujo reactivo con `Mono.fromCallable(...)`.
Impacto: si la construcción falla de forma síncrona, el error sale del pipeline.
Sugerencia: construye el request dentro del `Mono` y luego encadena el envío con `flatMap(...)`.
```
```

## Ejemplo Python

```md
[P2][PY-CONFIG] Secreto hardcodeado en código productivo

Ojo aquí con `PY-CONFIG`: el valor sensible quedó embebido en el módulo en vez de resolverse desde configuración/env vars.
Impacto: complica rotación de credenciales y expone secretos en el código.
Sugerencia: mueve el valor a `settings` o variable de entorno y consúmelo desde la configuración central del servicio.

Ejemplo sugerido:
```python
api_token = settings.notifications_api_token
```
```

## Comentario final del MR

Al cerrar la revisión:

- si hay hallazgos, dejar un comentario/resumen corto con:
  - número de hallazgos por severidad,
  - si hay bloqueantes,
  - y faltantes de evidencia (tests/build) si aplica.
- si no hay hallazgos, dejar una nota breve:

```md
Revisión completada: no encontré incumplimientos accionables contra las reglas canónicas aplicables a este MR.
Riesgos residuales: <si existen>.
```
