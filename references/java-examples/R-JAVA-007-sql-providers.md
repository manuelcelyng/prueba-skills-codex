# R-JAVA-007 — SQL Providers (named params + append opcional)

## ❌ Mal (concatenación de input)

```java
String sql = "SELECT * FROM lote WHERE estado = '" + estado + "'"; // ❌ inyección / hardcode
```

## ✅ Bien (parámetros nombrados)

```java
String sql = "SELECT * FROM lote WHERE estado = :estado";
return databaseClient.sql(sql)
    .bind("estado", estado)
    .map(rowMapper::map)
    .all();
```

## ✅ Bien (base query + `append` solo para filtros opcionales)

```java
StringBuilder sql = new StringBuilder("SELECT * FROM lote WHERE 1=1");
Map<String, Object> params = new HashMap<>();

if (estado != null) {
  sql.append(" AND estado = :estado");
  params.put("estado", estado);
}
```
