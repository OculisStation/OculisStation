#!/bin/sh
root="$(cd "$(dirname "$0")/.." && pwd)"
byond_bin="$(dirname "$(readlink -f "$(command -v DreamDaemon)")")"
# DreamDaemon finds the checkout's .so libraries here, and they need libbyond.so
export LD_LIBRARY_PATH="$root:$byond_bin${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$root/tools/build/build.sh" dm-test "$@"
