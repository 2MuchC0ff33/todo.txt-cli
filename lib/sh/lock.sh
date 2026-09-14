#!/bin/sh
# lib/sh/lock.sh - mkdir lock (mkdir-based locking).
set -eu
lock_acquire() {
  lockdir="$1"
  if mkdir "$lockdir" 2>/dev/null; then return 0; else return 1; fi
}
lock_release() { rmdir "$1" 2>/dev/null || true; }
