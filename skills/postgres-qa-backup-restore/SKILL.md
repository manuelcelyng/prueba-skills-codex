---
name: postgres-qa-backup-restore
description: Backup y restore de bases de datos PostgreSQL en ambiente QA usando pg_dump/pg_restore, incluyendo (1) backup full y data-only por schema, (2) esperar señal del usuario para ejecutar restore, (3) restaurar datos tras cambios de columnas/migraciones, (4) aplicar valores por defecto a columnas indicadas (ALTER COLUMN SET DEFAULT + UPDATE), y (5) opcionalmente eliminar tablas de un schema (o dropear el schema) con confirmación explícita. Usar cuando el usuario pida “backup de QA”, “dump”, “restaurar QA”, “pg_dump/pg_restore”, “cambiar columnas x,y,z”, o “eliminar tablas del esquema”.
metadata:
  scope: root
  auto_invoke:
    - "Backup/restore BD QA (Postgres)"
    - "pg_dump/pg_restore (schema)"
---

# Postgres QA Backup/Restore (pg_dump/pg_restore)

## Reglas de seguridad (OBLIGATORIAS)

- **Siempre** hacer primero un **backup FULL** antes de cualquier operación destructiva o restauración.
- **Nunca** ejecutar acciones destructivas sin confirmación explícita del usuario:
  - `DROP SCHEMA ... CASCADE`
  - `DROP TABLE ...`
  - Restauraciones con `--clean` / `--if-exists`
- Mostrar los comandos que vas a ejecutar y el **path de salida** del backup.
- Trabajar por **schema** cuando aplique (para no tocar otros esquemas).

## Flujo recomendado (2 fases)

### Fase A — Solo backup (y quedar en espera)

1) Pedir/confirmar inputs mínimos:
   - `PGHOST`, `PGPORT` (típico 5432), `PGDATABASE`, `PGUSER`
   - `PGSCHEMA` (schema objetivo)
   - Carpeta local para backups (`OUTDIR`)
2) Ejecutar:
   - **Backup FULL** (schema + data)
   - **Backup DATA-ONLY** (solo datos, excluyendo tablas de Liquibase)
3) Reportar:
   - Paths de los dumps generados, tamaño y (si es posible) checksum
4) **Detenerse** y decir: *“Backup listo. Avísame cuando continúo con restore/cambios.”*

### Fase B — Restore + defaults + (opcional) borrar tablas/schema (solo cuando el usuario lo indique)

1) Confirmar qué se va a hacer (y pedir confirmación explícita si es destructivo):
   - ¿Hay que **eliminar tablas del schema**? (Sí/No)
   - ¿O hay que **dropear el schema completo** y recrearlo? (Sí/No)
   - ¿Las migraciones del cambio de columnas (x,y,z) ya se aplicaron o las debe ejecutar el agente?
2) Ejecutar (según instrucción del usuario):
   - Drop schema/tablas (si aplica) **con confirmación**
   - Ejecutar migraciones (si aplica)
   - Restaurar data (`pg_restore --data-only ...`)
3) Aplicar defaults que el usuario indique:
   - Para cada `(schema.tabla.columna, default)`:
     - **Default para futuros inserts**:
       - `ALTER TABLE ... ALTER COLUMN ... SET DEFAULT ...;`
     - **Backfill de datos existentes** (si el usuario lo pide):
       - `UPDATE ... SET col = <default> WHERE col IS NULL;`
4) Validar conteos mínimos / smoke queries.

## Comandos rápidos (si no se usan scripts)

> Ver guía completa en `references/qa-backup-restore.md`.

### Backup FULL (por seguridad)

```bash
TS="$(date +%Y%m%d_%H%M%S)"
FULL_DUMP="$OUTDIR/${PGDATABASE}_${PGSCHEMA}_FULL_${TS}.dump"

pg_dump \
  --format=custom \
  --no-owner --no-acl \
  --schema="$PGSCHEMA" \
  --file="$FULL_DUMP"
```

### Backup DATA-ONLY (para reingresar data)

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

### Restore data-only

```bash
pg_restore \
  --data-only \
  --no-owner --no-acl \
  --schema="$PGSCHEMA" \
  --disable-triggers \
  --dbname="$PGDATABASE" \
  "$DATA_DUMP"
```

## Recursos del skill

### references/qa-backup-restore.md
Guía completa (paso a paso) para backup/restore + defaults + drop de tablas/schema.

### scripts/
- `pg_backup.sh`: genera dump FULL + DATA-ONLY por schema.
- `pg_restore_data.sh`: restaura DATA-ONLY por schema.
- `psql_drop_schema.sql`: dropea y recrea un schema (DESTRUCTIVO).
- `psql_drop_schema_tables.sql`: elimina todas las tablas de un schema (DESTRUCTIVO).

> Nota: estos scripts viven en este mismo folder del skill. Si ejecutas desde la raíz del repo, referencia el path `skills/postgres-qa-backup-restore/scripts/...`.
>
> En repos con AI Kit instalado, el path típico es: `.ai/skills/postgres-qa-backup-restore/scripts/...` (y `.claude/skills` / `.codex/skills` suelen ser symlinks a `.ai/skills`).
