#!/bin/sh
# tests/unit_filter_awk.posix.sh - unit tests for lib/awk/filter.awk stages.
# shellcheck disable=SC2250,SC2086,SC2164,SC2154,SC2312,SC2249,SC2094
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SB="$ROOT/var/tmp/sb_fawk"
rm -rf "$SB"
mkdir -p "$SB"
fail=0
check() {
  if [ "$2" = "$3" ]; then
    printf 'ok %s\n' "$1"
  else
    printf 'FAIL %s\n--- expected ---\n%s\n--- actual ---\n%s\n' "$1" "$2" "$3"
    fail=1
  fi
}
printf '%s\n' "1 Call mom" "2 (A) Buy milk" "3 x Done thing" >"$SB/numbered.txt"
: >"$SB/empty_terms.txt"
out="$(awk -v TERMS_FILE="$SB/empty_terms.txt" -f "$ROOT/lib/awk/filter.awk" "$SB/numbered.txt")"
check "filter-passthrough" "1 Call mom
2 (A) Buy milk
3 x Done thing" "$out"
printf '%s\n' "milk" >"$SB/t1.txt"
out="$(awk -v TERMS_FILE="$SB/t1.txt" -f "$ROOT/lib/awk/filter.awk" "$SB/numbered.txt")"
check "filter-include" "2 (A) Buy milk" "$out"
printf '%s\n' "MILK" >"$SB/t2.txt"
out="$(awk -v TERMS_FILE="$SB/t2.txt" -f "$ROOT/lib/awk/filter.awk" "$SB/numbered.txt")"
check "filter-fold" "2 (A) Buy milk" "$out"
printf '%s\n' "-done" >"$SB/t3.txt"
out="$(awk -v TERMS_FILE="$SB/t3.txt" -f "$ROOT/lib/awk/filter.awk" "$SB/numbered.txt")"
check "filter-exclude" "1 Call mom
2 (A) Buy milk" "$out"
printf '%s\r\n' "1 CR line" >"$SB/cr.txt"
out="$(awk -v TERMS_FILE="$SB/empty_terms.txt" -f "$ROOT/lib/awk/filter.awk" "$SB/cr.txt")"
check "filter-cr" "1 CR line" "$out"
printf '%s\n' "1 one" "" "3 three" >"$SB/gaps.txt"
out="$(awk -f "$ROOT/lib/awk/list.awk" "$SB/gaps.txt")"
check "list-gaps" "1 1 one
3 3 three" "$out"
printf '%s\n' "2  padded" >"$SB/pad.txt"
out="$(awk -f "$ROOT/lib/awk/format.awk" "$SB/pad.txt")"
check "format-sep" "2 padded" "$out"
rm -rf "$SB"
exit "$fail"
