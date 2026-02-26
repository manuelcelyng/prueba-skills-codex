# R-JAVA-012 — Naming de UseCases (evitar `execute`)

## ❌ Mal (genérico)

```java
public Mono<Resultado> execute(Comando cmd) { ... }
```

## ✅ Bien (intención explícita)

```java
public Mono<Resultado> ejecutarControlesLoteVencido(Comando cmd) { ... }
```
