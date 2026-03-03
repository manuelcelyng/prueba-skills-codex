-- DESTRUCTIVO: dropea y recrea un schema completo.
-- Uso:
--   psql -v ON_ERROR_STOP=1 -v schema='esquema_x' -f psql_drop_schema.sql

DO $$
BEGIN
  IF current_setting('is_superuser', true) IS NULL THEN
    -- noop: some managed PG don't expose this setting; keep script simple.
  END IF;
END $$;

DO $$
DECLARE
  s text := :'schema';
BEGIN
  IF s IS NULL OR length(trim(s)) = 0 THEN
    RAISE EXCEPTION 'Missing psql var: schema';
  END IF;

  EXECUTE format('DROP SCHEMA IF EXISTS %I CASCADE', s);
  EXECUTE format('CREATE SCHEMA %I', s);
END $$;

