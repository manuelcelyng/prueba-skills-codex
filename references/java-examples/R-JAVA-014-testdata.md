# R-JAVA-014 — Tests sin hardcode de negocio (usar `*TestData`)

## ❌ Mal (hardcode de estados/valores de negocio)

```java
var estado = "NUEVO"; // ❌ valor de negocio hardcodeado
```

## ✅ Bien (Constants o `*TestData`)

```java
var estado = LoteTestData.ESTADO_NUEVO;
```
