#!/bin/sh
# bin/todo.sh - POSIX sh orchestrator (glue only; domain logic lives in lib/lua, lib/awk).
# Usage: todo.sh [-fhpantvV] [-d todo_config] action [args...]
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
. "$ROOT/lib/shared/_lib.sh"
# shellcheck source=/dev/null
if [ -f "$ROOT/etc/todorc" ]; then . "$ROOT/etc/todorc"; fi
mkdir -p "$ROOT/var/log" "$ROOT/var/spool" "$ROOT/var/tmp" "$ROOT/home"
TMPDIR="$ROOT/var/tmp"
export TMPDIR
usage() { "$ROOT/lib/sh/usage.sh"; }
if [ "$#" -eq 0 ]; then
  usage >&2
  exit 1
fi
ACTION="$1"
shift
case "$ACTION" in
  -h | --help | help)
    usage
    exit 0
    ;;
  -V)
    printf '%s\n' "TODO.TXT POSIX-OS rewrite (Lua-core)"
    exit 0
    ;;
esac
if [ -x "$ROOT/libexec/$ACTION" ]; then
  exec "$ROOT/libexec/$ACTION" "$@"
fi
exec lua "$ROOT/lib/lua/actions.lua" "$ACTION" "$@"
