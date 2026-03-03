# Guía: backup de BD QA (PostgreSQL) + restore + defaults + drop de tablas/schema

Esta guía está pensada para que un agente IA la siga con seguridad.

## Objetivo (caso típico)

> “Necesito que hagas un **backup de QA** porque se van a cambiar las columnas **x, y, z**. Luego, cuando yo te indique, me ayudas a **restaurarla** y **colocar valores por default** a esas columnas según indique. Si te indico que elimines las **tablas del esquema**, lo haces.”

## Reglas de seguridad (OBLIGATORIAS)

1) Antes de tocar QA, generar **backup FULL**.
2) No ejecutar comandos destructivos sin confirmación explícita del usuario:
   - `DROP SCHEMA ... CASCADE`
   - `DROP TABLE ...`
3) Mostrar los comandos y archivos a generar antes de correrlos.
4) Preferir trabajar por **schema** (no por toda la BD) cuando sea posible.

---

## Prerrequisitos

- Acceso a la red/VPN donde vive QA.
- Tener `pg_dump`, `pg_restore` y `psql` disponibles.
  - Alternativa: usar Docker `postgres:<version>` para ejecutar `pg_dump/pg_restore` sin instalar.

---

## Variables recomendadas

```bash
export PGHOST="<host-qa>"
export PGPORT="<port-qa>"          # típico 5432
export PGDATABASE="<db-qa>"
export PGUSER="<user-qa>"
export PGPASSWORD="<password-qa>"  # o usar ~/.pgpass

export PGSCHEMA="<schema>"         # ej: esquema_recepcion / esquema_novedades
export OUTDIR="$HOME/db_backups"
mkdir -p "$OUTDIR"
```

---

## Fase A — Backup (y quedar en espera)

### A1) Backup FULL (por seguridad)

```bash
TS="$(date +%Y%m%d_%H%M%S)"
FULL_DUMP="$OUTDIR/${PGDATABASE}_${PGSCHEMA}_FULL_${TS}.dump"

pg_dump \
  --format=custom \
  --no-owner --no-acl \
  --schema="$PGSCHEMA" \
  --file="$FULL_DUMP"
```

### A2) Backup DATA-ONLY (para reingresar data después)

```bash
TS="$(date +%Y%m%d_%H%M%S)"
DATA_DUMP="$OUTDIR/${PGDATABASE}_${PGSCHEMA}_DATA_${TS}.dump"

pg_dump \
  --data-only \
  --format=custom \
  --no-owner --no-acl \
  --schema="$PGSCHEMA" \
  --exclude-table="$PGSCHEMA.databasechangelog" \
  --exclude-table="$PGSCHEMA.databasechangeloglock" \
  --file="$DATA_DUMP"
```

### A3) Reporte y espera

```bash
ls -lh "$FULL_DUMP" "$DATA_DUMP"
shasum -a 256 "$FULL_DUMP" "$DATA_DUMP" 2>/dev/null || true
```

Luego: **detenerse**. Informar al usuario que el backup está listo y esperar la instrucción para continuar.

---

## Fase B — Restore / cambios / defaults (solo cuando el usuario lo indique)

### B1) (Opcional) Eliminar tablas del schema (DESTRUCTIVO)

Requiere confirmación explícita del usuario.

**Opción 1: dropear el schema completo (más simple, más destructivo)**

```bash
psql -v ON_ERROR_STOP=1 \
  -c "DROP SCHEMA IF EXISTS ${PGSCHEMA} CASCADE;" \
  -c "CREATE SCHEMA ${PGSCHEMA};"
```

**Opción 2: eliminar solo tablas del schema**

> Nota: esto no siempre borra vistas/secuencias/funciones; si se requiere limpieza total, usar Opción 1.

```bash
psql -v ON_ERROR_STOP=1 -v schema="${PGSCHEMA}" \
  -f ".ai/skills/postgres-qa-backup-restore/scripts/psql_drop_schema_tables.sql"
```

> Alternativa (schema completo): `psql -v ON_ERROR_STOP=1 -v schema="${PGSCHEMA}" -f .ai/skills/postgres-qa-backup-restore/scripts/psql_drop_schema.sql`

### B2) Aplicar migraciones del cambio de columnas (x,y,z)

Esto depende del proyecto (Liquibase/Flyway/scripts). Si el agente no conoce cómo correrlas, pedir el comando exacto al usuario o ejecutar el pipeline estándar del repo.

### B3) Restaurar datos (data-only)

```bash
pg_restore \
  --data-only \
  --no-owner --no-acl \
  --schema="$PGSCHEMA" \
  --disable-triggers \
  --dbname="$PGDATABASE" \
  "$DATA_DUMP"
```

### B4) Colocar valores por default a columnas (según indique el usuario)

El usuario debe indicar:
- Tabla(s) afectadas (ej. `schema.tabla`)
- Columnas (x, y, z)
- Default por columna (ej. `'N/A'`, `0`, `true`, `now()`, `gen_random_uuid()`, etc.)
- Si quiere además **rellenar registros existentes** (backfill) o solo default futuro

**Patrón recomendado (por cada tabla/columna):**

```sql
-- 1) Default para inserts futuros
ALTER TABLE <schema>.<tabla>
  ALTER COLUMN <col> SET DEFAULT <default>;

-- 2) Backfill (opcional, recomendado si la columna queda NOT NULL)
UPDATE <schema>.<tabla>
SET <col> = <default>
WHERE <col> IS NULL;
```

**Ejemplo:**

```sql
ALTER TABLE esquema_novedades.tnov_solicitud_novedad
  ALTER COLUMN canal SET DEFAULT 'WEB';

UPDATE esquema_novedades.tnov_solicitud_novedad
SET canal = 'WEB'
WHERE canal IS NULL;
```

> Si luego se requiere `NOT NULL`, hacerlo **después** del backfill:
>
> `ALTER TABLE ... ALTER COLUMN ... SET NOT NULL;`

### B5) Validaciones rápidas

```bash
psql -v ON_ERROR_STOP=1 -c "select now(), current_database();"
psql -v ON_ERROR_STOP=1 -c "select count(*) from ${PGSCHEMA}.<tabla_clave>;"
```

---

## Alternativa: ejecutar pg_dump/pg_restore con Docker (sin instalar clientes)

**Backup (ejemplo FULL a archivo local):**

```bash
docker run --rm -e PGPASSWORD="$PGPASSWORD" postgres:16 \
  pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" \
  --format=custom --no-owner --no-acl --schema="$PGSCHEMA" \
  --file - > "$FULL_DUMP"
```

**Restore (ejemplo data-only desde archivo local):**

```bash
docker run --rm -e PGPASSWORD="$PGPASSWORD" -v "$OUTDIR:/out" postgres:16 \
  pg_restore -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" \
  --data-only --no-owner --no-acl --schema="$PGSCHEMA" --disable-triggers \
  "/out/$(basename "$DATA_DUMP")"
```
