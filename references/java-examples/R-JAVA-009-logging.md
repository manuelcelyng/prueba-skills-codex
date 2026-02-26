# R-JAVA-009 — Logging (traceId + placeholders + sin PII)

## ❌ Mal (concatenación + PII)

```java
log.info("Procesando usuario " + documento + " con lote " + idLote); // ❌ concat + PII
```

## ✅ Bien (placeholders, traceId primero, sin PII)

```java
log.info("{} Procesando lote {}", traceId, idLote);
```
