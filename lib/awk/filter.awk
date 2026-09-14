# filter.awk - case-sensitive substring/term filter (projection only).
# Usage: awk -v TERM=foo -f filter.awk file
{ line = $0; sub(/\r$/, "", line) }
length(TERM) == 0 || index(tolower(line), tolower(TERM)) > 0 { print }
