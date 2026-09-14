#!/bin/sh
# tests/unit_task_lua.posix.sh - Lua task model unit test.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
lua -e 'assert(_VERSION=="Lua 5.5","need 5.5")' || exit 1
mkdir -p "$ROOT/var/tmp"
printf '(A) 2026-09-15 Call mom +Family @phone\nx 2026-09-14 Done task\nplain task\n' >"$ROOT/var/tmp/unit_task.txt"
lua "$ROOT/tests/modules/task_check.lua" "$ROOT/var/tmp/unit_task.txt" | tr -d '\r'
