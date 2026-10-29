#!/bin/sh
# linux twin of dmeow-burn.cmd. juke only takes --flag=value, not --flag value
root="$(cd "$(dirname "$0")/.." && pwd)"
byond_bin="$(dirname "$(readlink -f "$(command -v DreamDaemon)")")"
# DreamDaemon finds libdmeow.so / librust_g.so here, and they need libbyond.so
export LD_LIBRARY_PATH="$root:$byond_bin${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$root/tools/build/build.sh" dmeow-burn "$@"
