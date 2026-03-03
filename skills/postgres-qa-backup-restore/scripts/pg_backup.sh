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
require_var OUTDIR

mkdir -p "$OUTDIR"

TS="$(date +%Y%m%d_%H%M%S)"
FULL_DUMP="${OUTDIR}/${PGDATABASE}_${PGSCHEMA}_FULL_${TS}.dump"
DATA_DUMP="${OUTDIR}/${PGDATABASE}_${PGSCHEMA}_DATA_${TS}.dump"

echo "[INFO] Writing FULL dump to: $FULL_DUMP"
pg_dump \
  --format=custom \
  --no-owner --no-acl \
  --schema="$PGSCHEMA" \
  --file="$FULL_DUMP"

echo "[INFO] Writing DATA-ONLY dump to: $DATA_DUMP"
pg_dump \
  --data-only \
  --format=custom \
  --no-owner --no-acl \
  --schema="$PGSCHEMA" \
  --exclude-table="$PGSCHEMA.databasechangelog" \
  --exclude-table="$PGSCHEMA.databasechangeloglock" \
  --file="$DATA_DUMP"

echo
echo "[OK] Dumps created:"
ls -lh "$FULL_DUMP" "$DATA_DUMP"

if command -v shasum >/dev/null 2>&1; then
  echo
  shasum -a 256 "$FULL_DUMP" "$DATA_DUMP"
fi

echo
echo "[NEXT] Export these paths to reuse later:"
echo "  export FULL_DUMP=\"$FULL_DUMP\""
echo "  export DATA_DUMP=\"$DATA_DUMP\""

