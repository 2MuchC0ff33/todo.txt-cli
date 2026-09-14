#!/bin/sh
# tests/run-tests.posix.sh - discover and run unit_*.posix.sh + cli_*.posix.sh.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
failures=0
ran=0
for t in tests/unit_*.posix.sh tests/cli_*.posix.sh; do
  [ -f "$t" ] || continue
  ran=$((ran + 1))
  echo "=== $(basename "$t") ==="
  if sh "$t"; then :; else failures=$((failures + 1)); fi
done
echo "ran=$ran failures=$failures"
[ "$failures" -eq 0 ]
