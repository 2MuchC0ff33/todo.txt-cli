#!/bin/sh
# lib/sh/todo_env.sh - runtime environment setup (sourced by bin/todo.sh).
# Requires ROOT set. Idempotent defaults: exported values win.
# Creates dirs/files, validates priority-on-add. Glue only.
# shellcheck disable=SC2250,SC2086,SC2164,SC2154,SC2312,SC2249,SC2094
set -eu
: "${TODO_DIR:=$HOME/.todo}"
: "${TODO_FILE:=$TODO_DIR/todo.txt}"
: "${DONE_FILE:=$TODO_DIR/done.txt}"
: "${REPORT_FILE:=$TODO_DIR/report.txt}"
: "${TODOTXT_VERBOSE:=1}"
: "${TODOTXT_FORCE:=0}"
: "${TODOTXT_PLAIN:=0}"
: "${TODOTXT_DATE_ON_ADD:=0}"
: "${TODOTXT_PRIORITY_ON_ADD:=}"
: "${TODOTXT_SORT_COMMAND:=env LC_COLLATE=C sort -f -k 2}"
export TODO_DIR TODO_FILE DONE_FILE REPORT_FILE
export TODOTXT_VERBOSE TODOTXT_FORCE TODOTXT_PLAIN TODOTXT_DATE_ON_ADD
export TODOTXT_PRIORITY_ON_ADD TODOTXT_SORT_COMMAND
case "$TODOTXT_PRIORITY_ON_ADD" in
  '') : ;;
  [A-Z]) : ;;
  *) die "TODOTXT_PRIORITY_ON_ADD should be a capital letter from A to Z (it is now \"$TODOTXT_PRIORITY_ON_ADD\")." ;;
esac
mkdir -p "$TODO_DIR" "$ROOT/var/log" "$ROOT/var/spool" "$ROOT/var/tmp"
[ -f "$TODO_FILE" ] || : >"$TODO_FILE"
[ -f "$DONE_FILE" ] || : >"$DONE_FILE"
[ -f "$REPORT_FILE" ] || : >"$REPORT_FILE"
