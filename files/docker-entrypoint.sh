#!/bin/bash
set -eoux pipefail

VOLUME=/farcry2
CONFIG="$VOLUME"/config
LOGS="$VOLUME"/logs

mkdir -p "$VOLUME"
mkdir -p "$CONFIG"
mkdir -p "$LOGS"

if [[ ! -f $CONFIG/server.cfg ]]; then
  # Copy default settings if server.cfg doesn't exist.
  cp /server.cfg "$CONFIG/server.cfg"
fi

# Change working directory.
cd /opt/farcry2/bin

export LD_PRELOAD=./patch.so
exec ./FarCry2_server \
  -dedicated "$CONFIG"/server.cfg \
  -logFile "$LOGS"/server.log \
  "$@"

