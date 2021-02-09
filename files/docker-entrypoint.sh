#!/bin/bash
set -eoux pipefail

VOLUME=/farcry2
CONFIG_DIR="$VOLUME"/config
LOG_DIR="$VOLUME"/logs

mkdir -p "$VOLUME" "$CONFIG_DIR" "$LOG_DIR"

if [[ ! -f "$CONFIG_DIR"/server.cfg ]]; then
    # Copy default settings if server.cfg doesn't exist.
    mv /server.cfg "$CONFIG_DIR/server.cfg"
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

export WINEDEBUG=-all
export LD_PRELOAD=./patch.so

exec xvfb-run -a \
    wine ./FC2ServerLauncher.exe \
    -dedicated "$CONFIG_DIR"/server.cfg \
    -logFile "$LOG_DIR"/server.log
