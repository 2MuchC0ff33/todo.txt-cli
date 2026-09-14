# TODO — POSIX-OS rewrite (`feature/2026-09-15-posix-os-rewrite`)

Tracks the Lua-core POSIX rewrite of this fork. Behaviour source of truth is
`todo.sh help`. Sync model: `docs/upstream-sync.txt` (consume-only; `master`
mirrors `todotxt/todo.txt-cli`). Rewrite notes: `docs/posix-rewrite.txt`.

Rule: an action counts as ported only with Lua/awk/sh code PLUS a golden
transcript in `tests/cli_*.posix.sh` and green gates (`shfmt -d`, `AUDIT
PASS`, `run-tests`, `tcc -Wall -Werror`).

## Done

- [x] Scaffold micro-modular POSIX-OS tree (`bin/`, `lib/sh|awk|lua|shared/`,
  `libexec/`, `src/`, `etc/`, `var/`, `srv/`, `home/`, `tests/`, `Makefile.posix`)
- [x] `add` / `a`, `addm`, `addto` (Lua `actions.lua` + `store.lua`)
- [x] `list` / `ls`, `listfile` / `lf` (awk `list|filter|format` + sort pipe)
- [x] `help` (usage surface), global opts `-d -t -T -v -f -p -a -V -h`
- [x] Gates skeleton: `env_probe`, `posix_scope_audit`, `run-tests` (5/5 green)
- [x] `src/todo_norm.c` + `src/todo_sort.c` compile under `tcc -Wall -Werror`
- [x] `docs/upstream-sync.txt`; upstream remote registered, in sync at `105fae6`

## Phase 2 — core mutations (Lua `actions.lua` + `store.lua`)

- [ ] `do` / `done` (append `x DATE`, archive hook)
- [ ] `del` / `rm` (term-strip variant + preserve-line-numbers mode)
- [ ] `pri` / `p` (set priority, uppercase validation)
- [ ] `depri` / `dp` (multi-item, comma-separated)
- [ ] `append` / `app` (sentence-delimiter spacing rule)
- [ ] `prepend` / `prep` (shared `replaceOrPrepend` path)
- [ ] `replace` (shared `replaceOrPrepend` path)
- [ ] `move` / `mv` (cross-file move)

## Phase 3 — lists and reports (awk-heavy, reuse `list.awk`/`filter.awk`)

- [ ] `listall` / `lsa` (number every line incl. blanks)
- [ ] `listcon` / `lsc` (contexts via `contexts.awk`)
- [ ] `listproj` / `lsprj` (projects via `projects.awk`)
- [ ] `listpri` / `lsp` (priority sort via `sort_pri_date.awk`)
- [ ] `report` (counts + `report.txt` aggregation)
- [ ] `listaddons` (enumerate `libexec/`)
- [ ] `shorthelp` (compact usage surface)

## Phase 4 — maintenance and compat

- [ ] `archive` (move `x` lines; wire `todo_norm` C helper into pipe)
- [ ] `deduplicate` (first-occurrence wins; Lua/C differential test)
- [ ] `command` + `TODOTXT_DEFAULT_ACTION` recursion semantics
- [ ] `todo_completion` port decision (POSIX `sh` completion vs drop)
- [ ] Colorization (`colorize.awk`, stays POSIX-1.2024 awk, no GNU-isms)

## Phase 5 — parity and merge endgame

- [ ] Full-matrix green: every legacy `tNNNN` behaviour has a POSIX transcript
- [ ] Legacy-vs-POSIX differential run over shared fixture corpus
- [ ] `Makefile.posix` `disttest` equivalent (stamped-VERSION run)
- [ ] Squash-merge feature into `master` (master diverges from upstream here;
  syncs switch from `--ff-only` to merge — see `docs/upstream-sync.txt`)

## Standing

- [ ] Check `git ls-remote upstream master` each work session; port fixes per rule
- [ ] Keep `AGENTS.md` and `docs/` in step with every port commit
