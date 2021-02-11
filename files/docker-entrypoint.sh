#!/bin/bash
set -eoux pipefail

VOLUME=/farcry2
CONFIG_DIR="$VOLUME"/config
LOG_DIR="$VOLUME"/logs
MAP_DIR="$VOLUME"/maps
HOME_DIR="$(eval echo ~$USER)"
FC2_DIR="$HOME_DIR"/My\ Games/Far\ Cry\ 2/Server

mkdir -p "$VOLUME" "$CONFIG_DIR" "$LOG_DIR" "$MAP_DIR" "$FC2_DIR"

if [[ ! -f "$CONFIG_DIR"/server.cfg ]]; then
    cp /server.cfg "$CONFIG_DIR"/server.cfg
fi

if [[ ! -L "$FC2_DIR"/dedicated_server.cfg ]]; then
    ln -s "$CONFIG_DIR"/server.cfg "$FC2_DIR"/dedicated_server.cfg
fi

if [[ "$EUID" -eq 0 ]]; then
    # Update the User and Group ID based on the PUID/PGID variables
    usermod -o -u "$PUID" "$USER"
    groupmod -o -g "$PGID" "$GROUP"

    # Take ownership of farcry2 data if running as root
    chown -R "$USER":"$GROUP" "$VOLUME" "$HOME_DIR"

    # Drop to the factorio user
    exec sudo -u "$USER" "$0" "$@"
fi

# Change working directory.
cd /opt/farcry2/bin

export WINEARCH=win32
export WINEDEBUG=-all
export LD_PRELOAD=./patch.so

exec xvfb-run -a \
    wine ./FC2ServerLauncher.exe \
    -logFile "$LOG_DIR"/server.log

#-dedicated Server/dedicated_server.cfg
