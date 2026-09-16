#!/bin/sh
# tests/env_probe.posix.sh - runtime presence + version pins for the POSIX-OS tree.
# Pins: lua 5.5.0, tcc 0.9.27, sqlite3 3.53.4, busybox make --posix (POSIX 2024).
set -u
fail=0
probe() {
	if type "$1" >/dev/null 2>&1; then :; else
		echo "MISS $1"
		fail=1
	fi
}
lua_v="$(lua -v 2>&1)"
case "$lua_v" in
*"Lua 5.5"*) : ;;
*)
	echo "PIN lua: $lua_v"
	fail=1
	;;
esac
tcc_v="$(tcc -vv 2>&1 | head -n 1)"
case "$tcc_v" in
*0.9.27*) : ;;
*)
	echo "PIN tcc: $tcc_v"
	fail=1
	;;
esac
sqlite_v="$(sqlite3 --version 2>&1 | head -n 1)"
case "$sqlite_v" in
3.53.4*) : ;;
*)
	echo "PIN sqlite3: $sqlite_v"
	fail=1
	;;
esac
if busybox make --posix -n -f "$(dirname "$0")/../Makefile.posix" >/dev/null 2>&1; then :; else
	echo "PIN busybox make --posix"
	fail=1
fi
for a in awk sed sort grep tr cksum date sh sqlite3; do probe "$a"; done
exit "$fail"
