/* todo_sort.c - decorate lines with pri rank for sort (reads stdin, writes rank<TAB>line).
 * Strict C99: headers stdbool/stddef/stdlib/string/stdio only.
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
    int rank = 99;
    if (n >= 3 && buf[0] == '(' && buf[1] >= 'A' && buf[1] <= 'Z' && buf[2] == ')')
      rank = (buf[1] - 'A') + 1;
    printf("%02d\t%s\n", rank, buf);
  }
  return 0;
}
