# R-JAVA-006 — Derived queries vs `@Query` vs `DatabaseClient`

## ❌ Mal (query simple “sobre-ingenierizada”)

```java
public interface LoteRepository extends ReactiveCrudRepository<LoteEntity, Long> {

  @Query("SELECT * FROM lote WHERE estado = :estado") // ❌ era simple
  Flux<LoteEntity> buscarPorEstado(String estado);
}
```

## ✅ Bien (derived query por nombre)

```java
public interface LoteRepository extends ReactiveCrudRepository<LoteEntity, Long> {
  Flux<LoteEntity> findAllByEstado(String estado);
}
```

## ✅ Bien (cuando sí aplica `DatabaseClient` / SQL Provider)

- Cuando hay joins complejos, subqueries, paginación no trivial, filtros dinámicos extensos, etc.
