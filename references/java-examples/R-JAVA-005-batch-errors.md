# R-JAVA-005 — Batch robusto (errores por elemento)

## ❌ Mal (un error aborta todo)

```java
public Mono<Void> publicarPorLote(Flux<Lote> lotes) {
  return lotes.flatMap(this::publicar) // si publicar falla -> aborta el flujo completo
      .then();
}
```

## ✅ Bien (aislar error por item/lote)

```java
public Mono<Void> publicarPorLote(Flux<Lote> lotes) {
  return lotes.concatMap(lote ->
          publicar(lote)
              .onErrorResume(ex -> registrarFalla(lote, ex).then(Mono.empty()))
      )
      .then();
}
```
