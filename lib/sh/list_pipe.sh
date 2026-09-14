#!/bin/sh
# lib/sh/list_pipe.sh - list pipeline stages (sourced by bin/todo.sh).
# Stage plan: awk number | awk filter | sort | awk format. Counts plus footer.
# shellcheck disable=SC2250,SC2086,SC2164,SC2154,SC2312,SC2249,SC2094
list_resolve_src() {
  cand="$1"
  case "$cand" in
    /*)
      if [ -f "$cand" ]; then
        printf '%s\n' "$cand"
        return 0
      fi
      ;;
  esac
  if [ -f "$TODO_DIR/$cand" ]; then
    printf '%s\n' "$TODO_DIR/$cand"
    return 0
  fi
  if [ -f "$cand" ]; then
    printf '%s\n' "$cand"
    return 0
  fi
  if [ -f "$TODO_DIR/$cand.txt" ]; then
    printf '%s\n' "$TODO_DIR/$cand.txt"
    return 0
  fi
  echo "TODO: File $cand does not exist." >&2
  return 1
}
list_pipeline() {
  src="$1"
  shift
  terms_file="$(portable_mktemp terms).$$"
  : >"$terms_file"
  for list_term in "$@"; do
    printf '%s\n' "$list_term" >>"$terms_file"
  done
  numbered="$(portable_mktemp numbered).$$"
  shown="$(portable_mktemp shown).$$"
  awk -f "$ROOT/lib/awk/list.awk" "$src" >"$numbered"
  total="$(awk 'END { print NR + 0 }' "$numbered")"
  awk -v TERMS_FILE="$terms_file" -f "$ROOT/lib/awk/filter.awk" "$numbered" | eval "$TODOTXT_SORT_COMMAND" | awk -f "$ROOT/lib/awk/format.awk" >"$shown"
  count="$(awk 'END { print NR + 0 }' "$shown")"
  cat "$shown"
  if [ "$TODOTXT_VERBOSE" -gt 0 ]; then
    echo "--"
    echo "$(get_prefix "$src"): $count of $total tasks shown"
  fi
  rm -f "$terms_file" "$numbered" "$shown"
}
