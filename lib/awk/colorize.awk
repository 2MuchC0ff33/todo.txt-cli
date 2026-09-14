# colorize.awk - placeholder colorizer (POSIX awk only; no GNU-isms).
{ line = $0; sub(/\r$/, "", line); print line }
