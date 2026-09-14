# _lib.awk - shared awk helpers (trim, strip CR, strip control pipes).
function trim(s) { gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", s); return s }
function strip_cr(s) { gsub(/\r$/, "", s); return s }
function strip_pipe(s) { gsub(/\|/, "", s); return s }
