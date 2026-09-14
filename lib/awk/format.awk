# format.awk - stage 4: final projection (CR strip, single-space separator).
# Colorization hook: plain output when COLOR_* env vars are unset.
{
  line = $0
  sub(/\r$/, "", line)
  sub(/[ \t][ \t]*/, " ", line)
  print line
}
