# number_listall.awk - number every line incl. blanks (listall parity stub).
{ line = $0; sub(/\r$/, "", line); printf "%d %s\n", NR, line }
