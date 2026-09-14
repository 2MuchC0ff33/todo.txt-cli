#!/bin/sh
# tests/_lib.sh - shared harness helpers (restore fixtures, clear logs).
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
restore_fixtures() { :; }
clear_log() { rm -f "$ROOT/var/log/todo.log"; }
