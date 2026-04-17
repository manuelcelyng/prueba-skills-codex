# Garnishment Naming Convention

## Contexto

Esta regla aplica a todos los microservicios, lambdas, modelos de dominio, contratos y traducciones relacionadas con descuentos de nómina por embargos.

## Regla principal

Todo descuento de nómina por embargo debe traducirse y modelarse en inglés usando el término **garnishment**. El tipo de embargo se define por su origen, no por una traducción literal del español.

## Tipos válidos de embargo

| Español | Inglés (canónico) |
|---------|-------------------|
| Embargo conciliatorio | `Voluntary garnishment` |
| Embargo judicial | `Judicial garnishment` |
| Embargo de alimentos | `Child support garnishment` |

## Regla de naming para información judicial

Cuando el embargo es judicial y los datos corresponden al juzgado o autoridad:

- Se **debe** usar el prefijo `COURT`
- **No** se debe usar el prefijo `JUDICIAL`

### Ejemplo

```java
// ❌ Incorrecto
public final String JUDICIAL_ACCOUNT_NUMBER = "050000907002";

// ✅ Correcto
public final String COURT_ACCOUNT_NUMBER = "050000907002";
```

Otros campos del juzgado:

```java
public final String COURT_NAME = "T.S. SALA CVL FAMILI ANTIOQUIA";
public final String COURT_PROCESS = "PRO123465";
public final String COURT_FILE_NUMBER = "EXP123456";
public final String COURT_ACCOUNT_NUMBER = "050000907002";
```

## Restricción

El término `seizure` **no debe usarse** en ningún contexto relacionado con nómina o descuentos salariales. Usar siempre `garnishment`.

## Aplicación

- **Obligatorio** en nuevos desarrollos
- En código existente, corregir solo si no genera impacto funcional (si tocás la clase y el cambio es seguro, aprovechá para corregir)
