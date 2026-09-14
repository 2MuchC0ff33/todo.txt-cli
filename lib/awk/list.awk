# list.awk - stage 1: number non-blank lines with physical line numbers.
# Blank/whitespace-only lines are dropped (legacy _format parity).
# Usage: awk -f list.awk file   ->   "NUM text"
{
  line = $0
  sub(/\r$/, "", line)
  if (line ~ /^[ \t]*$/) next
  printf "%d %s\n", NR, line
}
