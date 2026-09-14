#!/bin/sh
# lib/sh/usage.sh - short help (mirrors todo.sh help source of truth, subset).
set -eu
cat <<'EOF'
Usage: todo.sh [-fhpantvV] [-d todo_config] action [task_number] [task_description]
Actions: add a addm addto append app archive command del rm depri dp do done
  help list ls listall lsa listcon lsc listproj listfile lf move prepend pri
  replace report
EOF
