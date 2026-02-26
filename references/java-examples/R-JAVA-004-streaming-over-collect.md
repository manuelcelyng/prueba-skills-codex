# R-JAVA-004 — Streaming sobre materializar (`collectList` + `fromIterable`)

## ❌ Mal (materializa para reemitir)

```java
public Flux<Resultado> procesar(Flux<Item> items) {
  return items.collectList()
      .flatMapMany(list -> Flux.fromIterable(list))
      .flatMap(this::procesarItem);
}
```

## ✅ Bien (streaming directo; `concatMap` si secuencial/ordenado)

```java
public Flux<Resultado> procesar(Flux<Item> items) {
  return items.concatMap(this::procesarItem); // secuencial y preserva orden
}
```
