# R-JAVA-010 — Errores (BusinessException + ErrorCode)

## ❌ Mal (RuntimeException genérica al cliente)

```java
return port.obtener(id)
    .switchIfEmpty(Mono.error(new RuntimeException("No existe")));
```

## ✅ Bien (ErrorCode del micro + BusinessException)

```java
return port.obtener(id)
    .switchIfEmpty(Mono.error(new BusinessException(ErrorCode.LOTE_NO_EXISTE)));
```

**Entrypoint**: traduce a respuesta estándar y NO expone stacktrace.
