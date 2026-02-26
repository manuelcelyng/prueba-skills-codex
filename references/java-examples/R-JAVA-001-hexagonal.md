# R-JAVA-001 — Hexagonal/Clean (capas)

## ❌ Mal (reglas de negocio en infraestructura / entrypoint)

```java
// Anti-ejemplo: el router decide reglas de negocio y arma SQL.
public Mono<ServerResponse> cerrarLote(ServerRequest req) {
  return req.bodyToMono(CerrarLoteRequest.class)
      .flatMap(r -> databaseClient.sql("UPDATE lote SET estado = '" + r.estado() + "' WHERE id = " + r.id())
          .fetch().rowsUpdated()
      )
      .flatMap(rows -> ServerResponse.ok().build());
}
```

## ✅ Bien (entrypoint adapta, usecase decide, infra implementa)

```java
// Entrypoint: valida/adapta. NO decide negocio.
public Mono<ServerResponse> cerrarLote(ServerRequest req) {
  return req.bodyToMono(CerrarLoteRequest.class)
      .flatMap(r -> cerrarLoteUseCase.cerrarLote(r.id(), r.traceId()))
      .flatMap(result -> ServerResponse.ok().bodyValue(result));
}

// UseCase: orquesta reglas del dominio.
public Mono<CerrarLoteResponse> cerrarLote(Long idLote, String traceId) {
  return lotePort.obtener(idLote)
      .flatMap(lote -> reglasDeCierre.validar(lote))
      .flatMap(lotePort::cerrar)
      .map(this::toResponse);
}
```
