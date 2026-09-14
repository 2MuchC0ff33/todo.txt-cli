#!/bin/sh
# lib/shared/_lib.sh - shared logging + portable mktemp (portable temp names).
set -eu
log_msg() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$ROOT/var/log/todo.log"
}
portable_mktemp() {
  prefix="$1"
  n="$(cksum </dev/null 2>/dev/null || printf '0 0')"
  set -- $n
  printf '%s/%s.%s.%s' "$ROOT/var/tmp" "$prefix" "$$" "$1"
}
die() {
  printf '%s\n' "$*" >&2
  exit 1
}
get_prefix() {
  base="$(basename "$1")"
  base="${base%%.*}"
  printf '%s\n' "$base" | tr '[:lower:]' '[:upper:]'
}
