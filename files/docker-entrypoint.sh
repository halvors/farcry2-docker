#!/bin/bash
set -eoux pipefail

VOLUME=/farcry2
mkdir -p "$VOLUME"
mkdir -p "$CONFIG"
mkdir -p "$MAPS"

if [[ ! -f $CONFIG/server.cfg ]]; then
  # Copy default settings if server.cfg doesn't exist
  cp /server.cfg "$CONFIG/server.cfg"
fi

if [[ $(id -u) = 0 ]]; then
  # Update the User and Group ID based on the PUID/PGID variables
  usermod -o -u "$PUID" "$USER"
  groupmod -o -g "$PGID" "$GROUP"
  # Take ownership of farcry2 data if running as root
  chown -R "$USER":"$GROUP" "$VOLUME"

  # Drop to the farcry2 user
#  SU_EXEC="su farcry2 -c"
#else
#  SU_EXEC=""
fi

# shellcheck disable=SC2086
#exec $SU_EXEC /opt/farcry2/bin/FarCry2_server \
exec /opt/farcry2/bin/FarCry2_server \
  --dedicated /farcry2/config/server.cfg
  "$@"
