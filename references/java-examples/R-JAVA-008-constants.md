# R-JAVA-008 — Literales a `Constants`

## ❌ Mal (hardcode repetido)

```java
if ("APROBADO".equals(lote.getEstado())) { ... }
log.info("Lote APROBADO {}", lote.getId());
```

## ✅ Bien (Constants)

```java
if (LoteConstants.ESTADO_APROBADO.equals(lote.getEstado())) { ... }
log.info("{} {} {}", traceId, LoteLogs.LOTE_APROBADO, lote.getId());
```
