# todo.txt-cli

Bash implementation (`todo.sh`, ~1570 lines) of the todo.txt CLI. `todo_completion` =
Bash completion; `todo.cfg` = config template (installed, not read in place).
`todo.sh help` is the behaviour source of truth. GPL-3.0.

## Scope split (read first)
- **Repo code is deliberately Bash** (shopt/extglob/arrays) and CI (ubuntu/macos,
  bash + GNU make) is its execution target. Do NOT convert it to POSIX sh.
- **This Windows box is BusyBox-W32 v1.38.0.git (scoop mingit-busybox 2.55.0.5) + Lua
  5.5.0 + scoop tcc 0.9.27 + sqlite3 3.53.4, with `shfmt`/`shellcheck` on PATH — but no
  bash/make.** Anything you WRITE NEW here follows the elvis conformance constitution:
  `~/.local/src/projects/personal/elvis/AGENTS.md` (canonical utility allowlist, banned
  tools/options/constructs, gates).
- Domain map for new code: POSIX `sh` = orchestration/utility glue (skills: posix-sh,
  busybox-ash); POSIX `awk` = stream/text processing (posix-awk); Lua stdlib-only
  (`io/os/string/table`) = core general language (lua-glue); tcc-compatible C17 =
  perf-critical/system helpers only (c17-systems); sqlite3 3.53.4 = primary DB
  (sqlite3-posix; sh owns all invocations via `lib/sh/sqlite.sh`); POSIX `make` = new
  build scripts only (posix-make) — the repo `Makefile` is GNU, leave it alone.
- Canonical stack index: the global `posix-toolchain-stack` skill (sh=glue, awk=stream,
  Lua=primary, C17=hot path, sqlite=persistence, make=build, *rc=config,
  `etc/posix_allowlist.txt`=scope law). Scope law for new code: `etc/posix_allowlist.txt`.
- Run `shfmt -ln=posix` + `shellcheck --shell=sh` on new POSIX shell (both on PATH);
  never apply POSIX gates to the repo's Bash files.

## Persistence (sqlite3-backed, DB-truth)
- `TODO_DB` (default `$TODO_DIR/todo.db`, WAL) is the authoritative store; `todo.txt`/
  `done.txt` are byte-faithful DB exports regenerated after every mutation (blanks are
  rows, physical line numbers preserved).
- cksum reconciler: on every mutation action, `bin/todo.sh` re-imports a file when its
  `cksum` differs from the last-synced value in the `meta` table — hand-edited plaintext
  is picked up, then DB wins.
- `lib/sh/sqlite.sh` is the SOLE sqlite3 caller (frozen contract: `-batch`, `.bail on`,
  `.mode list`, heredoc SQL batches). Lua never shells out; it emits
  `apply|append|<file>|<text>` records that sh applies and then re-exports.

## Verification
- Full: `make test`. Single: `cd tests && ./tNNNN-name.sh`
  (`-v`, `-i` stop-on-first-fail, `--tee`, `--long-tests`; skips via
  `SKIP_TESTS='t1300? …'`). CI (master, ubuntu/macos): test → dist → disttest →
  install → uninstall → clean.
- `make disttest` re-runs the suite against built `dist/` (embedded VERSION).
  Version changes must pass both paths (see below).
- On this box `make test` cannot run (no make/bash) — rely on CI or Git Bash/WSL.
- POSIX-OS gates (feature branch): `busybox sh tests/env_probe.posix.sh` (version pins:
  lua 5.5.0, tcc 0.9.27, sqlite3 3.53.4, `busybox make --posix` dry-run),
  `busybox sh tests/posix_scope_audit.posix.sh` → `AUDIT PASS`,
  `busybox sh tests/run-tests.posix.sh`, `shfmt -ln=posix -d` (empty) on touched sh,
  `shellcheck --shell=sh` on touched sh, `busybox make --posix -n -f Makefile.posix`.
  Aggregate target: `busybox make --posix -f Makefile.posix check`.

## Version machinery
- `todo.sh:9` holds literal `VERSION="@DEV_VERSION@"`; gitignored `VERSION-FILE`
  alongside overrides it. Built by `GEN-VERSION-FILE` from `git describe --tags
  --dirty` (strip `v`, `-`→`.`, default `v0.0.0`); `make build` stamps it into `dist/`.
- `t0200-version.sh` branches on `@DEV_VERSION@` presence: root tree = dev path,
  `dist/` = embedded path.

## Tests (`tests/`, harness forked from git's)
- Bash `tNNNN-name.sh`; source `test-lib.sh` after `test_description`, end `test_done`.
- Per-test sandbox (`tests/trash directory.*`, HOME=sandbox, frozen `bin/date`,
  `LANG=C LC_ALL=C TZ=UTC TERM=dumb`, `TODO_*` unset).
- `test_todo_session` transcripts (`>>> cmd` + expected output); generate via
  `./testshell.sh`, replace sandbox paths with `$HOME`.
- **Never name a helper `t[0-9]{4}-*.sh`** — the Makefile globs those as tests.
- `.gitignore`: `todo.txt`/`done.txt`/`report.txt`, `VERSION-FILE` — never commit data.

## Repo conventions
- Route all file-editing sed through `todo.sh`'s `sed()` wrapper (todo.sh:32,
  emulates `-i.bak` for BSD/busybox sed); never `command sed`.
- The two embedded awk programs (todo.sh:978 colorization, todo.sh:1342 `listall`
  numbering) must stay POSIX-1.2024 awk — no GNU-isms (busybox awk locally).
- Extensions go in action scripts (`TODO_ACTIONS_DIR`); keep `todo.sh` core-only
  (upstream CONTRIBUTING).

## Git release pattern (elvis flow, `master` branch)
- Never commit directly to `master`: `git stash -u` → `git checkout -b <feature>` →
  `git stash pop` → work → `git add -A` + one squashed commit on the branch →
  `git checkout master` → `git merge --squash <feature>` → one commit with the same
  message → **push origin master is mandatory** → `git branch -D <feature>` →
  `git reflog expire --expire=now --all && git gc --aggressive --prune=now &&
  git fsck --full --strict` (expect silence).

## Upstream sync (fork consume-only model, full procedure: docs/upstream-sync.txt)
- Remotes: `origin` = this fork (sole push target); `upstream` =
  todotxt/todo.txt-cli (fetched, never pushed, never PR'd — upstream is Bash
  by constitution). One-time: `git remote add upstream
  https://github.com/todotxt/todo.txt-cli.git && git fetch upstream`.
- `master` stays a pristine upstream mirror (never commit the rewrite there);
  the POSIX-OS tree lives only on `feature/2026-09-15-posix-os-rewrite`.
- Sync order: `checkout master` → `fetch upstream` →
  `merge --ff-only upstream/master` → `push origin master` →
  `checkout feature/...` → inspect via `git log --oneline master@{1}..master` →
  `rebase master` → `push --force-with-lease` backup.
- Porting rule: syncing `master` does NOT fix `bin/`/`lib/`/`src/` — replicate
  each upstream behavioral fix in the Lua/awk/sh equivalent PLUS a
  `tests/cli_*.posix.sh` transcript assertion.
- Verify per sync: POSIX gates locally + legacy `make test` via CI.