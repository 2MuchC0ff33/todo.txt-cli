#!/bin/sh
# tests/cli_help.posix.sh - usage surface golden test.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
out="$(sh "$ROOT/lib/sh/usage.sh")"
case "$out" in *Usage:*) exit 0 ;; *)
  echo "BAD usage"
  exit 1
  ;;
esac
