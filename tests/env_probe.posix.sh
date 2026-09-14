#!/bin/sh
# tests/env_probe.sh - runtime presence checks (lua 5.5, tcc, busybox applets).
set -u
fail=0
if type lua >/dev/null 2>&1; then lua -v; else
  echo "MISS lua"
  fail=1
fi
if type tcc >/dev/null 2>&1; then tcc -vv 2>&1 | head -n 2; else
  echo "MISS tcc"
  fail=1
fi
for a in awk sed sort grep tr cksum date sh; do
  if type "$a" >/dev/null 2>&1; then :; else
    echo "MISS $a"
    fail=1
  fi
done
exit "$fail"
