#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting Eden with DISPLAY=${DISPLAY} and args: $*"
/Applications/eden-emu.AppImage --appimage-extract-and-run "$@"
