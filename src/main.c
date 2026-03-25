#include "todo/api.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void print_usage(const char* prog) {
    fprintf(stderr, "Usage: %s [--data-dir DIR] action [args]\n", prog);
    fprintf(stderr, "Actions:\n");
    fprintf(stderr, "  add <task>       Add a new task\n");
    fprintf(stderr, "  list             List tasks\n");
    fprintf(stderr, "  done <n>         Mark task n done\n");
    fprintf(stderr, "  report           Generate report\n");
}

static void set_env_var(const char* name, const char* value) {
#if defined(_WIN32) || defined(_WIN64)
    /* _putenv_s is available on MSVC and mingw */
    if (name && value)
        _putenv_s(name, value);
#else
    if (name && value)
        setenv(name, value, 1);
#endif
}

static void set_data_dir(const char* dir) {
    if (!dir || !dir[0])
        return;
    char buf[1024];
    if ((int)snprintf(buf, sizeof(buf), "%s/%s", dir, "todo.txt") < (int)sizeof(buf))
        set_env_var("TODO_FILE_PATH", buf);
    if ((int)snprintf(buf, sizeof(buf), "%s/%s", dir, "done.txt") < (int)sizeof(buf))
        set_env_var("DONE_FILE_PATH", buf);
    if ((int)snprintf(buf, sizeof(buf), "%s/%s", dir, "report.txt") < (int)sizeof(buf))
        set_env_var("REPORT_FILE_PATH", buf);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        print_usage(argv[0]);
        return 1;
    }

    int idx = 1;
    if (strcmp(argv[idx], "--data-dir") == 0 || strcmp(argv[idx], "-d") == 0) {
        if (argc <= idx + 1) {
            fprintf(stderr, "--data-dir requires a directory argument\n");
            return 1;
        }
        set_data_dir(argv[idx + 1]);
        idx += 2;
        if (idx >= argc) {
            print_usage(argv[0]);
            return 1;
        }
    }

    const char* action = argv[idx];
    if (strcmp(action, "add") == 0) {
        if (idx + 1 >= argc) {
            fprintf(stderr, "add requires a task description\n");
            return 1;
        }
        add_task(argv[idx + 1]);
    } else if (strcmp(action, "list") == 0) {
        list_tasks();
    } else if (strcmp(action, "done") == 0) {
        if (idx + 1 >= argc) {
            fprintf(stderr, "done requires a task number\n");
            return 1;
        }
        char* endptr = NULL;
        long v = strtol(argv[idx + 1], &endptr, 10);
        if (endptr == argv[idx + 1] || v <= 0) {
            fprintf(stderr, "Invalid task number: %s\n", argv[idx + 1]);
            return 1;
        }
        mark_done((int)v);
    } else if (strcmp(action, "report") == 0) {
        generate_report();
    } else if (strcmp(action, "help") == 0 || strcmp(action, "--help") == 0 ||
               strcmp(action, "-h") == 0) {
        print_usage(argv[0]);
    } else {
        fprintf(stderr, "Unknown command: %s\n", action);
        print_usage(argv[0]);
        return 1;
    }

    return 0;
}
