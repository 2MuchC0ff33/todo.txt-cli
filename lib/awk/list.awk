# list.awk - numbered listing (projection only; numbering like listall).
# Usage: awk -f list.awk file
{ line = $0; sub(/\r$/, "", line); printf "%d %s\n", NR, line }
