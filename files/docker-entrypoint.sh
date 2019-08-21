#!/bin/bash
set -eoux pipefail

VOLUME=/farcry2
mkdir -p "$VOLUME"

if [[ $(id -u) = 0 ]]; then
  # Update the User and Group ID based on the PUID/PGID variables
  usermod -o -u "$PUID" farcry2
  groupmod -o -g "$PGID" farcry2
  # Take ownership of farcry2 data if running as root
  chown -R farcry2:farcry2 "$VOLUME"

  # Drop to the farcry2 user
#  SU_EXEC="su farcry2 -c"
#else
#  SU_EXEC=""
fi

# shellcheck disable=SC2086
#exec $SU_EXEC /opt/farcry2/bin/FarCry2_server \
exec /opt/farcry2/bin/FarCry2_server \
  --dedicated=dedicated_server.cfg
  "$@"
