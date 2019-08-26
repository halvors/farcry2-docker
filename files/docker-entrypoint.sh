#!/bin/bash
set -eoux pipefail

VOLUME=/farcry2
CONFIG="$VOLUME"/config
LOG="$VOLUME"/log

mkdir -p "$VOLUME"
mkdir -p "$CONFIG"
mkdir -p "$LOGS"

if [[ ! -f $CONFIG/server.cfg ]]; then
  # Copy default settings if server.cfg doesn't exist.
  cp /server.cfg "$CONFIG/server.cfg"
fi

if [[ $(id -u) = 0 ]]; then
  # Update the User and Group ID based on the PUID/PGID variables
  usermod -o -u "$PUID" "$USER"
  groupmod -o -g "$PGID" "$GROUP"
  # Take ownership of farcry2 data if running as root
  chown -R "$USER":"$GROUP" "$VOLUME"
fi

# Change working directory.
cd /opt/farcry2/bin

export LD_PRELOAD=./patch.so
exec ./FarCry2_server \
  -dedicated "$CONFIG"/server.cfg \
  -logFile "$LOG"/server.log \
  "$@"
