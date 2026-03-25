/* Public API wrapping existing todo functions (minimal compatibility) */
#ifndef TODO_API_H
#define TODO_API_H

#ifdef __cplusplus
extern "C" {
#endif

void add_task(const char* task);
void list_tasks(void);
void mark_done(int task_number);
void generate_report(void);

#ifdef __cplusplus
}
#endif

#endif /* TODO_API_H */
