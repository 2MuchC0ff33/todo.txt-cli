#!/bin/sh
# bin/todo.sh - POSIX sh orchestrator (glue only; domain logic in lib/lua, lib/awk).
# Usage: todo.sh [-fhpantvV] [-d todo_config] action [args...]
# shellcheck disable=SC2250,SC2086,SC2164,SC2154,SC2312,SC2249,SC2094
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
. "$ROOT/lib/shared/_lib.sh"
# shellcheck source=/dev/null
. "$ROOT/lib/sh/todo_env.sh"
# shellcheck source=/dev/null
. "$ROOT/lib/sh/sqlite.sh"
if [ -f "$ROOT/etc/todorc" ]; then
	# shellcheck source=/dev/null
	. "$ROOT/etc/todorc"
fi
mkdir -p "$ROOT/var/log" "$ROOT/var/spool" "$ROOT/var/tmp" "$ROOT/home"
TMPDIR="$ROOT/var/tmp"
export TMPDIR
usage() { "$ROOT/lib/sh/usage.sh"; }
while getopts "d:tTvfVhpa" opt; do
	case "$opt" in
	d)
		if [ -r "$OPTARG" ]; then
			# shellcheck source=/dev/null
			. "$OPTARG"
		else
			die "Fatal Error: Cannot read configuration file $OPTARG"
		fi
		;;
	t) TODOTXT_DATE_ON_ADD=1 ;;
	T) TODOTXT_DATE_ON_ADD=0 ;;
	v) TODOTXT_VERBOSE=$((TODOTXT_VERBOSE + 1)) ;;
	f) TODOTXT_FORCE=1 ;;
	p) TODOTXT_PLAIN=1 ;;
	a) : ;;
	V)
		printf '%s\n' "TODO.TXT POSIX-OS rewrite (Lua-core)"
		exit 0
		;;
	h)
		usage
		exit 0
		;;
	*)
		usage >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))
export TODOTXT_DATE_ON_ADD TODOTXT_VERBOSE TODOTXT_FORCE TODOTXT_PLAIN
if [ "$#" -eq 0 ]; then
	usage >&2
	exit 1
fi
ACTION="$(printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]')"
shift
if [ -x "$ROOT/libexec/$ACTION" ]; then
	exec "$ROOT/libexec/$ACTION" "$@"
fi
case "$ACTION" in
help)
	usage
	exit 0
	;;
list | ls)
	# shellcheck source=/dev/null
	. "$ROOT/lib/sh/list_pipe.sh"
	list_pipeline "$TODO_FILE" "$@"
	;;
listfile | lf)
	# shellcheck source=/dev/null
	. "$ROOT/lib/sh/list_pipe.sh"
	if [ "$#" -gt 0 ] && list_resolve_src "$1" >/dev/null 2>&1; then
		src="$(list_resolve_src "$1")"
		shift
		list_pipeline "$src" "$@"
	else
		list_pipeline "$TODO_FILE" "$@"
	fi
	;;
*) # System Lua writes CRLF on Windows: stdout goes through tr -d '\r'
	# (stderr streams live so prompts keep working; exit code preserved).
	# DB-truth: reconcile hand-edited files, then apply Lua's apply records
	# via lib/sh/sqlite.sh and re-export the touched files byte-faithfully.
	db_prepare
	lua_out="$(portable_mktemp luaout).$$"
	lua_clean="$(portable_mktemp luaclean).$$"
	lua_status=0
	lua "$ROOT/lib/lua/actions.lua" "$ACTION" "$@" >"$lua_out" || lua_status=$?
	tr -d '\r' <"$lua_out" >"$lua_clean"
	if [ "$lua_status" -eq 0 ]; then
		touched=""
		while IFS= read -r line; do
			case "$line" in
			apply\|append\|*)
				rest="${line#apply|append|}"
				file="${rest%%|*}"
				text="${rest#*|}"
				db_append "$file" "$text"
				if [ "$TODOTXT_VERBOSE" -gt 0 ]; then
					count="$(db_count "$file")"
					printf '%s %s\n' "$count" "$text"
					printf '%s: %s added.\n' "$(get_prefix "$(export_path "$file")")" "$count"
				fi
				case " $touched " in
				*" $file "*) : ;;
				*) touched="$touched $file" ;;
				esac
				;;
			*) printf '%s\n' "$line" ;;
			esac
		done <"$lua_clean"
		for f in $touched; do
			db_export_file "$f" "$(export_path "$f")"
		done
	else
		cat "$lua_clean"
	fi
	rm -f "$lua_out" "$lua_clean"
	exit "$lua_status"
	;;
esac
