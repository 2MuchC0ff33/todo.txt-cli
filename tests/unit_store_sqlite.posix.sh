#!/bin/sh
# tests/unit_store_sqlite.posix.sh - sqlite3 store layer unit tests (DB-truth).
# shellcheck disable=SC2250,SC2086,SC2164,SC2154,SC2312,SC2249,SC2094,SC1091
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SB="$ROOT/var/tmp/sb_sqlite"
rm -rf "$SB"
mkdir -p "$SB"
export TODO_DIR="$SB" TODO_FILE="$SB/todo.txt" DONE_FILE="$SB/done.txt" REPORT_FILE="$SB/report.txt"
export TODO_DB="$SB/todo.db"
: >"$TODO_FILE"
: >"$DONE_FILE"
. "$ROOT/lib/shared/_lib.sh"
. "$ROOT/lib/sh/sqlite.sh"
fail=0
check() {
	if [ "$2" = "$3" ]; then
		printf 'ok %s\n' "$1"
	else
		printf 'FAIL %s\n--- expected ---\n%s\n--- actual ---\n%s\n' "$1" "$2" "$3"
		fail=1
	fi
}

db_init
check "wal" "wal" "$(sqlite3 -batch "$TODO_DB" "PRAGMA journal_mode;")"
check "init-empty" "0" "$(db_count "todo.txt")"

db_import_file "todo.txt" "$TODO_FILE"
check "import-empty" "0" "$(db_count "todo.txt")"

db_append "todo.txt" "Call mom +Family @phone"
check "append-count" "1" "$(db_count "todo.txt")"
db_export_file "todo.txt" "$TODO_FILE"
check "export" "Call mom +Family @phone" "$(cat "$TODO_FILE")"

printf '%s\n' "(B) second task +Proj" "" "(A) First task" >"$TODO_FILE"
db_import_file "todo.txt" "$TODO_FILE"
db_export_file "todo.txt" "$TODO_FILE"
check "blank-roundtrip" "(B) second task +Proj

(A) First task" "$(cat "$TODO_FILE")"
check "blank-kind" "blank" "$(sqlite3 -batch "$TODO_DB" "SELECT kind FROM lines WHERE file='todo.txt' AND id=2;")"

printf '%s\n' "external edit" >>"$TODO_FILE"
if db_needs_import "todo.txt" "$TODO_FILE"; then
	printf 'ok reconcile-detects\n'
else
	printf 'FAIL reconcile-detects\n'
	fail=1
fi
db_import_file "todo.txt" "$TODO_FILE"
check "reconcile-import" "external edit" "$(awk 'END { print }' "$TODO_FILE")"
if db_needs_import "todo.txt" "$TODO_FILE"; then
	printf 'FAIL reconcile-settles\n'
	fail=1
else
	printf 'ok reconcile-settles\n'
fi

printf '%s\n' "x 2026-01-01 Done thing" >"$DONE_FILE"
db_import_file "done.txt" "$DONE_FILE"
check "done-status" "done" "$(sqlite3 -batch "$TODO_DB" "SELECT status FROM lines WHERE file='done.txt' AND id=1;")"
check "done-date" "2026-01-01" "$(sqlite3 -batch "$TODO_DB" "SELECT done_date FROM lines WHERE file='done.txt' AND id=1;")"

db_append "done.txt" "Another done"
check "append-done-count" "2" "$(db_count "done.txt")"
db_export_file "done.txt" "$DONE_FILE"
check "export-done" "x 2026-01-01 Done thing
Another done" "$(cat "$DONE_FILE")"

rm -rf "$SB"
exit "$fail"
