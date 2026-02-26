# R-JAVA-015 — `*TestData` como utility consistente

## ❌ Mal (estado mutable + nombres crípticos)

```java
public class LoteTestData {
  static int counter = 0; // ❌ estado global mutable
  static Lote b1() { ... } // ❌ nombre críptico
}
```

## ✅ Bien (`@UtilityClass` + nombres descriptivos)

```java
@UtilityClass
public class LoteTestData {
  public static final String ESTADO_NUEVO = "NUEVO";

  public static Lote loteNuevoConFechaCorteVencida() { ... }
}
```
