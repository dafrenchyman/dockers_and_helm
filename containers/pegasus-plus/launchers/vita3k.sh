#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting Vita3K with DISPLAY=${DISPLAY} and args: $*"
/Applications/vita3k.AppImage --appimage-extract-and-run "$@"
