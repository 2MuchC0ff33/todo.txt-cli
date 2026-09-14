# projects.awk - emit +projects one per line.
{
  line = $0; sub(/\r$/, "", line)
  n = split(line, w, /[ \t]+/)
  for (i = 1; i <= n; i++) if (substr(w[i], 1, 1) == "+" && length(w[i]) > 1) print substr(w[i], 2)
}
