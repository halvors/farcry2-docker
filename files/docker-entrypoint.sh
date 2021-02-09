#!/bin/bash
set -eoux pipefail

VOLUME=/farcry2
CONFIG="$VOLUME"/config
LOG="$VOLUME"/log

mkdir -p "$VOLUME"
mkdir -p "$CONFIG"
mkdir -p "$LOG"

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
  # Drop to the factorio user
  SU_EXEC="su-exec farcry2"
else
  SU_EXEC=""
fi

# Change working directory.
cd /opt/farcry2/bin

#export DISPLAY=:0
#Xvfb :0 -screen 0 800x600x16 &

LD_PRELOAD=./patch.so xvfb-run wine ./FC2ServerLauncher.exe

#xvfb-run wine ./FC2ServerLauncher.exe \
#    -dedicated "$CONFIG"/server.cfg \
#    -logFile "$LOG"/server.log \
#    "$@"
