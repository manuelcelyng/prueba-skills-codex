# R-JAVA-003 — Uso correcto de Reactor (sin `subscribe()` manual)

## ❌ Mal (side-effects + subscribe manual)

```java
public Mono<Void> ejecutar() {
  obtenerMensajes()
      .doOnNext(m -> audit.log(m)) // side-effect no controlado
      .subscribe();                // ❌ dispara ejecución fuera del flujo
  return Mono.empty();
}
```

## ✅ Bien (side-effects controlados y composición)

```java
public Mono<Void> ejecutar() {
  return obtenerMensajes()
      .flatMap(m -> audit.log(m).thenReturn(m))
      .then();
}
```
