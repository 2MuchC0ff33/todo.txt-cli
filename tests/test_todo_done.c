#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "todo/api.h"

int test_mark_done(void) {
    /* prepare fixture */
    FILE* f = fopen("todo.txt", "w");
    if (!f)
        return 1;
    fprintf(f, "first task\nsecond task\nthird task\n");
    fclose(f);
    remove("done.txt");

    /* mark second as done */
    mark_done(2);

    /* check done.txt contains second task */
    f = fopen("done.txt", "r");
    if (!f)
        return 2;
    char buf[256];
    if (!fgets(buf, sizeof(buf), f)) {
        fclose(f);
        return 3;
    }
    fclose(f);
    if (strstr(buf, "second task") == NULL)
        return 4;

    /* check todo.txt no longer contains second task */
    f = fopen("todo.txt", "r");
    if (!f)
        return 5;
    int found = 0;
    while (fgets(buf, sizeof(buf), f)) {
        if (strstr(buf, "second task")) {
            found = 1;
            break;
        }
    }
    fclose(f);
    if (found)
        return 6;

    return 0;
}
