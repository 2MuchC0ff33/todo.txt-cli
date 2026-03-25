#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "todo/api.h"

int main(void) {
    /* Clean state */
    remove("todo.txt");
    remove("done.txt");
    remove("report.txt");

    /* Test add */
    add_task("simple one");
    add_task("simple two");

    FILE* f = fopen("todo.txt", "r");
    if (!f) {
        fprintf(stderr, "todo.txt not created\n");
        return 1;
    }
    fclose(f);

    /* Test mark_done */
    mark_done(1);
    f = fopen("done.txt", "r");
    if (!f) {
        fprintf(stderr, "done.txt not created\n");
        return 2;
    }
    fclose(f);

    /* Test report */
    generate_report();
    f = fopen("report.txt", "r");
    if (!f) {
        fprintf(stderr, "report.txt not created\n");
        return 3;
    }
    fclose(f);

    printf("simple tests passed\n");
    return 0;
}
