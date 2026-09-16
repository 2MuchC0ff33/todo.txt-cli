#!/bin/sh
# tests/posix_scope_audit.posix.sh - static conformance scan; prints AUDIT PASS on clean.
# Scope: NEW POSIX-OS tree only (bin lib libexec src etc/todorc* tests/*.posix.sh
# tests/modules tests/lib). Legacy Bash (todo.sh, tests/tNNNN*, test-lib.sh,
# todo_completion, Makefile, GEN-VERSION-FILE) is deliberately Bash per AGENTS.md
# and is NEVER scanned.
# Banned tools/options mirror the elvis constitution (canonical utility allowlist);
# sqlite3 is admitted but confined to lib/sh/sqlite.sh (production code).
# shellcheck disable=SC2250,SC2086,SC2164,SC2154,SC2312,SC2249,SC2094
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
violations=0
report() {
	violations=$((violations + 1))
	printf 'VIOLATION [%s] %s:%s: %s\n' "$1" "$2" "$3" "$4"
}
FILES="$(find "$ROOT/bin" "$ROOT/lib" "$ROOT/libexec" "$ROOT/src" -type f \( -name '*.sh' -o -name '*.awk' -o -name '*.lua' -o -name '*.c' \) 2>/dev/null)"
FILES="$FILES $(find "$ROOT/tests" -maxdepth 1 -type f -name '*.posix.sh' ! -name 'posix_scope_audit.posix.sh' 2>/dev/null)"
FILES="$FILES $(find "$ROOT/tests/modules" "$ROOT/tests/lib" -type f \( -name '*.lua' -o -name '*.sh' \) 2>/dev/null)"
[ -f "$ROOT/etc/todorc.sample" ] && FILES="$FILES $ROOT/etc/todorc.sample"
[ -f "$ROOT/Makefile.posix" ] && FILES="$FILES $ROOT/Makefile.posix"
for f in $FILES; do
	[ -f "$f" ] || continue
	ln=0
	while IFS= read -r text; do
		ln=$((ln + 1))
		code="$text"
		case "$code" in
		\#*) continue ;;
		esac
		case "$f" in
		*.lua) case "$code" in --*) continue ;; esac ;;
		esac
		case "$text" in
		*portable_mktemp*) : ;;
		*getopts*) : ;; # ash builtin getopts is allowlisted; banned applet is getopt
		*aria2c* | *md5sum* | *sha256sum* | *sha1sum* | *sha3sum* | *sha512sum* | *curl* | *httpd* | *uptime* | *readlink* | *realpath* | *xxd* | *shuf* | *timeout* | *usleep* | *truncate* | *whoami* | *iconv* | *getopt* | *io.popen* | *__attribute__* | *typeof* | *IGNORECASE* | *systime* | *strftime* | */dev/stderr* | */dev/tcp* | *"bc "* | *"dc "* | *"tar "* | *"stat "* | *"bash "* | *"seq "* | *"link "* | *"nc "* | *"join "* | *"nl "* | *"which "* | *mktemp*)
			report "banned" "$f" "$ln" "$text"
			;;
		esac
		case "$text" in
		*'grep -x'* | *'grep -w'* | *'grep -o'* | *'grep -r'* | *'grep -A'* | *'grep -B'* | *'grep -z'* | *'grep -m'* | *'touch -t'* | *'touch -d'* | *'touch -r'* | *'touch -a'* | *'touch -m'* | *'diff -u'* | *'find -quit'* | *'find -delete'* | *'sed -i'* | *'sort -m'* | *'wc -m'* | *'env -i'* | *'date -d'* | *'date -I'* | *'date -R'*)
			report "banned-opt" "$f" "$ln" "$text"
			;;
		esac
		case "$f" in
		*.sh | *.sample | *Makefile.posix)
			case "$text" in
			*portable_mktemp*) : ;;
			*'command -v'* | *'local '* | *'source '* | *flock* | *'which '* | *mktemp* | *stat\ * | *'\[\['* | *'function '*)
				report "banned-sh" "$f" "$ln" "$text"
				;;
			esac
			;;
		esac
		case "$f" in
		*.sh) case "$text" in '#!/bin/sh'*) ;; '#!'*) report "shebang" "$f" "$ln" "$text" ;; esac ;;
		esac
	done <"$f"
done
# sqlite3 confinement: production code may invoke sqlite3 only from lib/sh/sqlite.sh
for f in $FILES; do
	case "$f" in
	*/lib/sh/sqlite.sh | */tests/*) : ;;
	*)
		while IFS= read -r text; do
			case "$text" in
			\#* | --*) continue ;;
			esac
			case "$text" in
			*sqlite3*) report "sqlite3-outside-wrapper" "$f" 0 "$text" ;;
			esac
		done <"$f"
		;;
	esac
done
if [ "$violations" -eq 0 ]; then
	printf 'AUDIT PASS\n'
	exit 0
fi
exit 1
