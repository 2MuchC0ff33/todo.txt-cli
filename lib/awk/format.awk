# format.awk - pass-through formatter with CR strip (projection only).
{ line = $0; sub(/\r$/, "", line); print line }
