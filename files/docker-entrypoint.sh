#!/bin/bash
set -eoux pipefail

FACTORIO_VOL=/factorio

# shellcheck disable=SC2086
exec $SU_EXEC /opt/factorio/bin/x64/factorio
#  --port "$PORT" \
#  --start-server-load-latest \
#  --server-settings "$CONFIG/server-settings.json" \
#  --server-banlist "$CONFIG/server-banlist.json" \
#  --rcon-port "$RCON_PORT" \
#  --server-whitelist "$CONFIG/server-whitelist.json" \
#  --use-server-whitelist \
#  --server-adminlist "$CONFIG/server-adminlist.json" \
#  --rcon-password "$(cat "$CONFIG/rconpw")" \
#  --server-id /factorio/config/server-id.json \
  "$@"

