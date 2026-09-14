# filter.awk - stage 2: include/exclude term filter (projection only).
# Terms come from TERMS_FILE (one per line). A leading "-" excludes.
# Match is case-insensitive substring on the whole numbered line.
# Usage: awk -v TERMS_FILE=terms -f filter.awk numbered.txt
BEGIN {
  nterms = 0
  while ((getline t < TERMS_FILE) > 0) {
    sub(/\r$/, "", t)
    terms[++nterms] = t
  }
}
{
  line = $0
  sub(/\r$/, "", line)
  low = tolower(line)
  ok = 1
  for (i = 1; i <= nterms; i++) {
    t = terms[i]
    if (substr(t, 1, 1) == "-") {
      pat = tolower(substr(t, 2))
      if (pat != "" && index(low, pat) > 0) { ok = 0; break }
    } else {
      pat = tolower(t)
      if (pat != "" && index(low, pat) == 0) { ok = 0; break }
    }
  }
  if (ok) print line
}
