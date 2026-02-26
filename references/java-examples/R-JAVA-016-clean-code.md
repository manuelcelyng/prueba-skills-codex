# R-JAVA-016 — Clean code (anti-patrones comunes)

## ❌ Mal (duplicación + magic numbers + import estrella)

```java
import java.util.*; // ❌

if (items.size() > 5) { ... } // ❌ magic number sin contexto
if (items.size() > 5) { ... } // ❌ duplicación
```

## ✅ Bien

```java
import java.util.List;

private static final int MAX_ITEMS = 5;

if (items.size() > MAX_ITEMS) { ... }
```
