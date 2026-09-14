#!/bin/sh
# tests/cli_list.posix.sh - golden transcripts for list/ls/listfile + filters.
# shellcheck disable=SC2250,SC2086,SC2164,SC2154,SC2312,SC2249,SC2094
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SB="$ROOT/var/tmp/sb_list"
rm -rf "$SB"
mkdir -p "$SB"
export TODO_DIR="$SB" TODO_FILE="$SB/todo.txt" DONE_FILE="$SB/done.txt" REPORT_FILE="$SB/report.txt"
export TODOTXT_VERBOSE=1 TODOTXT_FORCE=1 TODOTXT_DATE_ON_ADD=0 TODOTXT_PRIORITY_ON_ADD=""
printf '%s\n' "(B) second task +Proj" "plain task @ctx" "" "(A) First task" "x 2026-01-01 Done one" >"$SB/todo.txt"
fail=0
check() {
  if [ "$2" = "$3" ]; then
    printf 'ok %s\n' "$1"
  else
    printf 'FAIL %s\n--- expected ---\n%s\n--- actual ---\n%s\n' "$1" "$2" "$3"
    fail=1
  fi
}
out="$(sh "$ROOT/bin/todo.sh" list)"
check "list-all" "4 (A) First task
1 (B) second task +Proj
2 plain task @ctx
5 x 2026-01-01 Done one
--
TODO: 4 of 4 tasks shown" "$out"
out="$(sh "$ROOT/bin/todo.sh" ls task)"
check "list-term" "4 (A) First task
1 (B) second task +Proj
2 plain task @ctx
--
TODO: 3 of 4 tasks shown" "$out"
out="$(sh "$ROOT/bin/todo.sh" ls TASK)"
check "list-case-fold" "4 (A) First task
1 (B) second task +Proj
2 plain task @ctx
--
TODO: 3 of 4 tasks shown" "$out"
out="$(sh "$ROOT/bin/todo.sh" ls -done)"
check "list-exclude" "4 (A) First task
1 (B) second task +Proj
2 plain task @ctx
--
TODO: 3 of 4 tasks shown" "$out"
out="$(sh "$ROOT/bin/todo.sh" ls task -plain)"
check "list-include-exclude" "4 (A) First task
1 (B) second task +Proj
--
TODO: 2 of 4 tasks shown" "$out"
out="$(sh "$ROOT/bin/todo.sh" ls nomatch)"
check "list-empty" "--
TODO: 0 of 4 tasks shown" "$out"
out="$(TODOTXT_VERBOSE=0 sh "$ROOT/bin/todo.sh" ls)"
check "list-quiet" "4 (A) First task
1 (B) second task +Proj
2 plain task @ctx
5 x 2026-01-01 Done one" "$out"
printf '%s\n' "other line one" "(A) other two" >"$SB/other.txt"
out="$(sh "$ROOT/bin/todo.sh" listfile other.txt)"
check "listfile" "2 (A) other two
1 other line one
--
OTHER: 2 of 2 tasks shown" "$out"
rm -rf "$SB"
exit "$fail"
