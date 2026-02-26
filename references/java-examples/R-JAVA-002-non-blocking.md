# R-JAVA-002 — No bloquear (WebFlux/R2DBC)

## ❌ Mal (`block()` / espera activa)

```java
public Mono<Void> procesar() {
  var lote = lotePort.obtener(id).block(); // ❌ rompe el modelo reactivo
  Thread.sleep(200);                       // ❌ espera activa
  return publisher.publicar(lote);
}
```

## ✅ Bien (composición reactiva)

```java
public Mono<Void> procesar() {
  return lotePort.obtener(id)
      .delayElement(Duration.ofMillis(200)) // si aplica y está justificado
      .flatMap(publisher::publicar);
}
```
