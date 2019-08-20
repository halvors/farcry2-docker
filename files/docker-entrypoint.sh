#!/bin/bash
set -eoux pipefail

# shellcheck disable=SC2086
exec /opt/farcry2/bin/FarCry2_server \
  "$@"

