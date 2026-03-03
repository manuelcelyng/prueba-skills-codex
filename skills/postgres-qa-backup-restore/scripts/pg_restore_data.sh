#!/usr/bin/env bash
set -euo pipefail

require_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "[ERROR] Missing env var: $name" >&2
    exit 1
  fi
}

require_var PGHOST
require_var PGPORT
require_var PGDATABASE
require_var PGUSER
require_var PGSCHEMA
require_var DATA_DUMP

if [[ ! -f "$DATA_DUMP" ]]; then
  echo "[ERROR] DATA_DUMP not found: $DATA_DUMP" >&2
  exit 1
fi

echo "[INFO] Restoring DATA-ONLY dump: $DATA_DUMP"
pg_restore \
  --data-only \
  --no-owner --no-acl \
  --schema="$PGSCHEMA" \
  --disable-triggers \
  --dbname="$PGDATABASE" \
  "$DATA_DUMP"

echo "[OK] Restore finished."

