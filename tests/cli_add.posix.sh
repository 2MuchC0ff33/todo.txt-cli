#!/bin/sh
# tests/cli_add.posix.sh - golden transcripts for add/addm/addto (Lua-core).
# shellcheck disable=SC2250,SC2086,SC2164,SC2154,SC2312,SC2249,SC2094
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SB="$ROOT/var/tmp/sb_add"
rm -rf "$SB"
mkdir -p "$SB"
export TODO_DIR="$SB" TODO_FILE="$SB/todo.txt" DONE_FILE="$SB/done.txt" REPORT_FILE="$SB/report.txt"
export TODOTXT_VERBOSE=1 TODOTXT_FORCE=1 TODOTXT_DATE_ON_ADD=0 TODOTXT_PRIORITY_ON_ADD=""
: >"$TODO_FILE"
fail=0
check() {
  if [ "$2" = "$3" ]; then
    printf 'ok %s\n' "$1"
  else
    printf 'FAIL %s\n--- expected ---\n%s\n--- actual ---\n%s\n' "$1" "$2" "$3"
    fail=1
  fi
}
out="$(sh "$ROOT/bin/todo.sh" add "Call mom +Family @phone")"
check "add-basic" "1 Call mom +Family @phone
TODO: 1 added." "$out"
check "add-basic-file" "Call mom +Family @phone" "$(cat "$SB/todo.txt")"
out="$(sh "$ROOT/bin/todo.sh" add "(a) Lower task")"
check "add-upper-pri" "2 (A) Lower task
TODO: 2 added." "$out"
TODAY="$(date +%Y-%m-%d)"
out="$(TODOTXT_DATE_ON_ADD=1 sh "$ROOT/bin/todo.sh" add "(B) Dated task")"
check "add-date-pri" "3 (B) $TODAY Dated task
TODO: 3 added." "$out"
out="$(TODOTXT_DATE_ON_ADD=1 sh "$ROOT/bin/todo.sh" add "No pri task")"
check "add-date-nopri" "4 $TODAY No pri task
TODO: 4 added." "$out"
out="$(TODOTXT_PRIORITY_ON_ADD=C sh "$ROOT/bin/todo.sh" add "Pri task")"
check "add-pri-on-add" "5 (C) Pri task
TODO: 5 added." "$out"
out="$(TODOTXT_PRIORITY_ON_ADD=C sh "$ROOT/bin/todo.sh" add "(A) Keeps pri")"
check "add-pri-kept" "6 (A) Keeps pri
TODO: 6 added." "$out"
out="$(sh "$ROOT/bin/todo.sh" addm "multi one
multi two")"
check "addm" "7 multi one
TODO: 7 added.
8 multi two
TODO: 8 added." "$out"
printf '%s\n' "x 2026-01-01 Done thing" >"$SB/done.txt"
out="$(sh "$ROOT/bin/todo.sh" addto "done.txt" "Another done")"
check "addto" "2 Another done
DONE: 2 added." "$out"
if sh "$ROOT/bin/todo.sh" addto "nodir" "task" 2>/dev/null; then
  printf 'FAIL addto-missing (exit 0)\n'
  fail=1
else
  printf 'ok addto-missing\n'
fi
out="$(TODOTXT_VERBOSE=0 sh "$ROOT/bin/todo.sh" add "Quiet task")"
check "add-quiet" "" "$out"
check "add-quiet-file" "Quiet task" "$(awk 'END { print }' "$SB/todo.txt")"
rm -rf "$SB"
exit "$fail"
