#include <check.h>
#include <stdio.h>
#include <stdlib.h>

#include "todo/api.h"

START_TEST(test_add_and_list) {
    /* Make sure we start fresh */
    remove("todo.txt");
    add_task("unit test task");
    FILE* f = fopen("todo.txt", "r");
    ck_assert_ptr_nonnull(f);
    fclose(f);
}
END_TEST

START_TEST(test_add_multiple) {
    remove("todo.txt");
    add_task("a one");
    add_task("a two");
    FILE* f = fopen("todo.txt", "r");
    ck_assert_ptr_nonnull(f);
    char buf[256];
    int lines = 0;
    while (fgets(buf, sizeof(buf), f))
        lines++;
    fclose(f);
    ck_assert_int_gt(lines, 1);
}
END_TEST

Suite* todo_suite(void) {
    Suite* s = suite_create("todo");
    TCase* tc_core = tcase_create("core");
    tcase_add_test(tc_core, test_add_and_list);
    tcase_add_test(tc_core, test_add_multiple);
    suite_add_tcase(s, tc_core);
    return s;
}

int main(void) {
    int number_failed;
    Suite* s = todo_suite();
    SRunner* sr = srunner_create(s);
    srunner_run_all(sr, CK_NORMAL);
    number_failed = srunner_ntests_failed(sr);
    srunner_free(sr);
    return (number_failed == 0) ? 0 : 1;
}
