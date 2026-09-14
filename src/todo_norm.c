/* todo_norm.c - normalize todo.txt lines on stdin to stdout (--pipe only).
 * Strict C99: headers stdbool/stddef/stdlib/string/stdio only.
 * Strips CR, squeezes inner whitespace runs to one space, trims ends,
 * drops blank lines (archive defrag parity).
 */
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

int main(void) {
  char buf[8192];
  while (fgets(buf, sizeof buf, stdin) != NULL) {
    size_t n = strlen(buf);
    while (n > 0 && (buf[n-1] == '\n' || buf[n-1] == '\r')) buf[--n] = '\0';
    char out[8192];
    size_t o = 0;
    bool in_space = true;
    size_t i = 0;
    while (i < n && (buf[i] == ' ' || buf[i] == '\t')) i++;
    for (; i < n && o + 2 < sizeof out; i++) {
      if (buf[i] == ' ' || buf[i] == '\t') {
        if (!in_space) { out[o++] = ' '; in_space = true; }
      } else { out[o++] = buf[i]; in_space = false; }
    }
    if (o > 0 && out[o-1] == ' ') o--;
    out[o] = '\0';
    if (o == 0) continue;
    fputs(out, stdout);
    fputc('\n', stdout);
  }
  return 0;
}
