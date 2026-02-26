# R-JAVA-018 — Tests de SQL Provider (cláusulas + params)

## ❌ Mal (assert del SQL completo)

```java
assertThat(sql).isEqualTo("SELECT * FROM lote WHERE 1=1 AND ..."); // ❌ frágil
```

## ✅ Bien (cláusulas críticas + params)

```java
assertThat(sql).contains("FROM lote");
assertThat(sql).contains("estado = :estado");
assertThat(params).containsEntry("estado", "APROBADO");
```
