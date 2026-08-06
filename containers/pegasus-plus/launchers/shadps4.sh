#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting shadPS4 with DISPLAY=${DISPLAY} and args: $*"
/Applications/shadps4-sdl.AppImage --appimage-extract-and-run "$@"
