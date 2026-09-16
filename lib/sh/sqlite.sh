#!/bin/sh
# lib/sh/sqlite.sh - SOLE sqlite3 caller for the POSIX-OS rewrite.
# Frozen contract (mirrors elvis, adapted for row-granular ops):
#   - sh owns every sqlite3 invocation; Lua never shells out.
#   - `sqlite3 -batch`, `.bail on` (default in batch), `.mode list`.
#   - SQL is passed as heredoc batches or single -batch arguments; no .import.
#   - Reconcile uses `cksum` (allowlisted) stored in the meta table; no stat.
# Requires: ROOT, TODO_DIR, TODO_FILE, DONE_FILE, TODO_DB (set by todo_env.sh).
# shellcheck disable=SC2250,SC2086,SC2164,SC2154,SC2312,SC2249,SC2094
set -eu

: "${TODO_KEY:=$(basename "$TODO_FILE")}"
: "${DONE_KEY:=$(basename "$DONE_FILE")}"

export_path() {
	case "$1" in
	"$TODO_KEY") printf '%s\n' "$TODO_FILE" ;;
	"$DONE_KEY") printf '%s\n' "$DONE_FILE" ;;
	*) printf '%s\n' "$TODO_DIR/$1" ;;
	esac
}

db_init() {
	[ -n "${TODO_DB:-}" ] || die "TODO_DB unset"
	mkdir -p "$(dirname "$TODO_DB")"
	sqlite3 -batch "$TODO_DB" <"$ROOT/lib/schema.sql" >/dev/null
}

db_sync_marker() {
	file="$1"
	path="$2"
	[ -f "$path" ] || return 0
	cur="$(cksum "$path")"
	sqlite3 -batch "$TODO_DB" "INSERT OR REPLACE INTO meta(key,value) VALUES('cksum:$file','$cur');" >/dev/null
}

db_needs_import() {
	file="$1"
	path="$2"
	[ -f "$path" ] || return 1
	cur="$(cksum "$path")"
	stored="$(sqlite3 -batch "$TODO_DB" "SELECT value FROM meta WHERE key='cksum:$file';")"
	[ "$cur" != "$stored" ]
}

db_import_file() {
	file="$1"
	path="$2"
	[ -f "$path" ] || return 0
	{
		printf "DELETE FROM lines WHERE file='%s';\n" "$file"
		n=0
		while IFS= read -r line; do
			n=$((n + 1))
			if [ -z "$line" ]; then
				printf "INSERT INTO lines(file,id,kind,text,status,done_date,archived) VALUES('%s',%s,'blank','','todo',NULL,0);\n" "$file" "$n"
			else
				esc="$(printf '%s\n' "$line" | sed "s/'/''/g")"
				case "$line" in
				"x "*)
					status="done"
					dd="$(printf '%s\n' "$line" | sed -n 's/^x \([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\).*/\1/p')"
					[ -n "$dd" ] || dd="NULL"
					;;
				*)
					status="todo"
					dd="NULL"
					;;
				esac
				if [ "$dd" = "NULL" ]; then
					printf "INSERT INTO lines(file,id,kind,text,status,done_date,archived) VALUES('%s',%s,'task','%s','%s',NULL,0);\n" "$file" "$n" "$esc" "$status"
				else
					printf "INSERT INTO lines(file,id,kind,text,status,done_date,archived) VALUES('%s',%s,'task','%s','%s','%s',0);\n" "$file" "$n" "$esc" "$status" "$dd"
				fi
			fi
		done <"$path"
	} | sqlite3 -batch "$TODO_DB" >/dev/null
	db_sync_marker "$file" "$path"
}

db_is_tracked() {
	file="$1"
	sqlite3 -batch "$TODO_DB" "SELECT 1 FROM lines WHERE file='$file' LIMIT 1;" | grep -q .
}

db_tracked_files() {
	sqlite3 -batch "$TODO_DB" "SELECT DISTINCT file FROM lines ORDER BY file;"
}

db_append() {
	file="$1"
	text="$2"
	path="$(export_path "$file")"
	if [ -f "$path" ] && ! db_is_tracked "$file"; then
		db_import_file "$file" "$path"
	fi
	esc="$(printf '%s\n' "$text" | sed "s/'/''/g")"
	sqlite3 -batch "$TODO_DB" "INSERT INTO lines(file,id,kind,text,status,done_date,archived) SELECT '$file', COALESCE(MAX(id),0)+1, 'task', '$esc', 'todo', NULL, 0 FROM lines WHERE file='$file';" >/dev/null
}

db_count() {
	file="$1"
	sqlite3 -batch "$TODO_DB" "SELECT COUNT(*) FROM lines WHERE file='$file';"
}

db_export_file() {
	file="$1"
	path="$2"
	sqlite3 -batch "$TODO_DB" ".mode list" "SELECT text FROM lines WHERE file='$file' ORDER BY id;" | tr -d '\r' >"$path"
	db_sync_marker "$file" "$path"
}

db_reconcile() {
	file="$1"
	path="$2"
	if db_needs_import "$file" "$path"; then
		db_import_file "$file" "$path"
	fi
}

db_prepare() {
	db_init
	db_reconcile "$TODO_KEY" "$TODO_FILE"
	db_reconcile "$DONE_KEY" "$DONE_FILE"
	for f in $(db_tracked_files); do
		case "$f" in
		"$TODO_KEY" | "$DONE_KEY") : ;;
		*) db_reconcile "$f" "$(export_path "$f")" ;;
		esac
	done
}
