# sort_pri_date.awk - decorate with pri key for external sort (projection only).
# Emits: pri-rank \t NR \t line ; pri A=1 ... Z=26, none=99.
{
  line = $0; sub(/\r$/, "", line)
  rank = 99
  if (match(line, /^\([A-Z]\)/)) {
    c = substr(line, 2, 1)
    rank = index("ABCDEFGHIJKLMNOPQRSTUVWXYZ", c)
  }
  printf "%02d\t%d\t%s\n", rank, NR, line
}
