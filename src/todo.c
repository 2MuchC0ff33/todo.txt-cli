/* Keep original simple implementation but expose through api header */
#include "todo/api.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TASK_LENGTH 1024
/* Default filenames; can be overridden at runtime via environment variables
   TODO_FILE_PATH, DONE_FILE_PATH, REPORT_FILE_PATH for testability and
   portability. */
#ifndef TODO_FILE
#define TODO_FILE_DEFAULT "todo.txt"
#else
#define TODO_FILE_DEFAULT TODO_FILE
#endif
#ifndef DONE_FILE
#define DONE_FILE_DEFAULT "done.txt"
#else
#define DONE_FILE_DEFAULT DONE_FILE
#endif
#ifndef REPORT_FILE
#define REPORT_FILE_DEFAULT "report.txt"
#else
#define REPORT_FILE_DEFAULT REPORT_FILE
#endif

static const char* get_path_or_default(const char* envname, const char* def) {
    const char* v = getenv(envname);
    return (v && v[0]) ? v : def;
}

static const char* todo_file_path(void) {
    return get_path_or_default("TODO_FILE_PATH", TODO_FILE_DEFAULT);
}

static const char* done_file_path(void) {
    return get_path_or_default("DONE_FILE_PATH", DONE_FILE_DEFAULT);
}

static const char* report_file_path(void) {
    return get_path_or_default("REPORT_FILE_PATH", REPORT_FILE_DEFAULT);
}

void add_task(const char* task) {
    if (!task)
        return;
    FILE* file = fopen(todo_file_path(), "a");
    if (!file) {
        perror("Error opening todo file");
        return;
    }
    fprintf(file, "%s\n", task);
    fclose(file);
    printf("Added task: %s\n", task);
}

void list_tasks(void) {
    FILE* file = fopen(todo_file_path(), "r");
    if (!file) {
        /* no todo file is not fatal */
        return;
    }
    char line[MAX_TASK_LENGTH];
    int task_number = 1;
    while (fgets(line, sizeof(line), file)) {
        printf("%d. %s", task_number++, line);
    }
    fclose(file);
}

void mark_done(int task_number) {
    if (task_number <= 0)
        return;
    FILE* todo_file = fopen(todo_file_path(), "r");
    if (!todo_file) {
        return;
    }

    FILE* done_file = fopen(done_file_path(), "a");
    if (!done_file) {
        fclose(todo_file);
        return;
    }

    FILE* temp_file = fopen("temp.txt", "w");
    if (!temp_file) {
        fclose(todo_file);
        fclose(done_file);
        return;
    }

    char line[MAX_TASK_LENGTH];
    int current_task = 1;
    while (fgets(line, sizeof(line), todo_file)) {
        if (current_task == task_number) {
            fprintf(done_file, "%s", line);
        } else {
            fprintf(temp_file, "%s", line);
        }
        current_task++;
    }

    fclose(todo_file);
    fclose(done_file);
    fclose(temp_file);

    /* best-effort replace */
    /* best-effort replace using paths resolved at runtime */
    remove(todo_file_path());
    rename("temp.txt", todo_file_path());

    printf("Task %d marked as done.\n", task_number);
}

void generate_report(void) {
    FILE* todo_file = fopen(todo_file_path(), "r");
    FILE* done_file = fopen(done_file_path(), "r");
    FILE* report_file = fopen(report_file_path(), "w");

    if (!report_file) {
        if (todo_file)
            fclose(todo_file);
        if (done_file)
            fclose(done_file);
        return;
    }

    int todo_count = 0;
    char line[MAX_TASK_LENGTH];
    if (todo_file) {
        while (fgets(line, sizeof(line), todo_file)) {
            todo_count++;
        }
    }

    int done_count = 0;
    if (done_file) {
        while (fgets(line, sizeof(line), done_file)) {
            done_count++;
        }
    }

    fprintf(report_file, "Remaining tasks: %d\nCompleted tasks: %d\n", todo_count, done_count);

    if (todo_file)
        fclose(todo_file);
    if (done_file)
        fclose(done_file);
    fclose(report_file);

    printf("Report generated: Remaining tasks - %d, Completed tasks - %d\n", todo_count,
           done_count);
}

/* main moved to src/main.c so this file only provides the library functions */
