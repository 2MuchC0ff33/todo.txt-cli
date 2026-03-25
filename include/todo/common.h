/* Common definitions for todo project */
#ifndef TODO_COMMON_H
#define TODO_COMMON_H

#include <stdbool.h>
#include <stddef.h>

typedef enum todo_err {
    TODO_OK = 0,
    TODO_ERR_IO,
    TODO_ERR_PARSE,
    TODO_ERR_NOT_FOUND,
    TODO_ERR_INVALID_ARG,
    TODO_ERR_OOM,
} todo_err_t;

#endif /* TODO_COMMON_H */
