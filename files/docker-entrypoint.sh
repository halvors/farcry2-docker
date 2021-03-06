#!/bin/bash
set -eoux pipefail

VOLUME=/farcry2
CONFIG_DIR="$VOLUME"/config
LOG_DIR="$VOLUME"/logs
MAP_DIR="$VOLUME"/maps

HOME_DIR="$(eval echo ~$USER)"
FC2_DIR="$HOME_DIR"/My\ Games/Far\ Cry\ 2

mkdir -p "$VOLUME" "$CONFIG_DIR" "$LOG_DIR" "$MAP_DIR" "$FC2_DIR"/Server

if [[ ! -f "$CONFIG_DIR"/server.cfg ]]; then
    cp /server.cfg "$CONFIG_DIR"/server.cfg
fi

# Symlink files from volume to the correct location inside the container.
if [[ ! -L "$FC2_DIR"/Server/dedicated_server.cfg ]]; then
    ln -s "$CONFIG_DIR"/server.cfg "$FC2_DIR"/Server/dedicated_server.cfg
fi

if [[ ! -L "$FC2_DIR"/user\ maps ]]; then
    ln -s "$MAP_DIR" "$FC2_DIR"/user\ maps
fi

if [[ "$EUID" -eq 0 ]]; then
<<<<<<< HEAD
#if [[ $(id -u) = 0 ]]; then
=======
>>>>>>> linux-patch
    # Update the User and Group ID based on the PUID/PGID variables
    usermod -o -u "$PUID" "$USER"
    groupmod -o -g "$PGID" "$GROUP"

    # Take ownership of farcry2 data if running as root
<<<<<<< HEAD
    chown -R "$USER":"$GROUP" "$VOLUME"

    # Drop to the farcry2 user
    #exec su "$USER" "$0"
=======
    chown -R "$USER":"$GROUP" "$VOLUME" "$HOME_DIR"

    # Drop to the factorio user
    exec sudo -u "$USER" "$0" "$@"
>>>>>>> linux-patch
fi

# Change working directory.
cd /opt/farcry2/bin

<<<<<<< HEAD
export WINEARCH=win32
export WINEDEBUG=-all
export LD_PRELOAD=./patch.so

exec xvfb-run -a \
    wine ./FC2ServerLauncher.exe -logFile "$LOG_DIR/server.log"

# Does not work? -dedicated CONFIG_DIR/server.cfg
#    wine ./FC2ServerLauncher.exe -dedicated CONFIG_DIR/server.cfg -logFile LOG_DIR/server.log
=======
#export WINEARCH=win32
#export WINEDEBUG=-all
export LD_PRELOAD=./patch.so

exec xvfb-run -a \
     wine ./FC2ServerLauncher.exe \
     -logFile "$LOG_DIR"/server.log

#-dedicated Server/dedicated_server.cfg
>>>>>>> linux-patch
