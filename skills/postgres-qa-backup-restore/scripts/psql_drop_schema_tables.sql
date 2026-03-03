-- DESTRUCTIVO: elimina todas las TABLAS de un schema (no borra vistas/funciones si existen).
-- Uso:
--   psql -v ON_ERROR_STOP=1 -v schema='esquema_x' -f psql_drop_schema_tables.sql

DO $$
DECLARE
  s text := :'schema';
  r record;
BEGIN
  IF s IS NULL OR length(trim(s)) = 0 THEN
    RAISE EXCEPTION 'Missing psql var: schema';
  END IF;

  FOR r IN
    SELECT tablename
    FROM pg_tables
    WHERE schemaname = s
  LOOP
    EXECUTE format('DROP TABLE IF EXISTS %I.%I CASCADE', s, r.tablename);
  END LOOP;
END $$;

