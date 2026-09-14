#!/bin/sh
# lib/sh/config.sh - validate required config vars.
set -eu
config_require() {
  if [ -z "${TODO_FILE:-}" ]; then
    echo "TODO_FILE unset" >&2
    exit 1
  fi
}
