# TODO — POSIX-OS rewrite (`feature/2026-09-15-posix-os-rewrite`)

Tracks the Lua-core POSIX rewrite of this fork. Behaviour source of truth is
`todo.sh help`. Sync model: `docs/upstream-sync.txt` (consume-only; `master`
mirrors `todotxt/todo.txt-cli`). Rewrite notes: `docs/posix-rewrite.txt`.

Domain tags: `sh` = orchestration/pipes/exit codes only; `lua` = task model +
state transitions (stdlib `io/os/string/table` only); `awk` = stream
projection; `c99` = `--pipe` hot-path filters only (`tcc -Wall -Werror`).

Rule: an action counts as ported only with code PLUS a golden transcript in
`tests/cli_*.posix.sh` and green gates (`shfmt -d`, `AUDIT PASS`, `run-tests`).

## Done

- [x] Scaffold micro-modular POSIX-OS tree (`bin/`, `lib/sh|awk|lua|shared/`,
  `libexec/`, `src/`, `etc/`, `var/`, `srv/`, `home/`, `tests/`, `Makefile.posix`)
- [x] `add` / `a`, `addm`, `addto` (`lua`: `actions.lua` + `store.lua`)
- [x] `list` / `ls`, `listfile` / `lf` (`awk`: `list|filter|format` + sort pipe)
- [x] `help` (usage surface), global opts `-d -t -T -v -f -p -a -V -h`
- [x] Gates: `env_probe`, `posix_scope_audit`, `run-tests` (5/5 green)
- [x] `src/todo_norm.c` + `src/todo_sort.c` compile under `tcc -Wall -Werror`
- [x] `docs/upstream-sync.txt`; upstream remote registered, sync at `105fae6`

## Phase 2 — core mutations

Shared first (`lua`): `store.get_line` (1-indexed physical line, blanks kept;
replaces `getTodo`'s `sed "$item!d"`), `store.replace_line`
(read-modify-write), `store.blank_or_delete` (preserve-numbers mode), and a
`confirm` helper (prompt to stderr + `io.read("*l")`, `y` confirms; skipped
when `FORCE=1`, which tests always set — POSIX `read` has no `-e`/`-N1`).

- [ ] `do` / `done` (`lua` + `sh` re-exec). Parse via `task.lua`; skip `^x `
  lines (stderr `already marked done`, exit 1, multi-item status accumulates).
  Strip `(P)`, prepend `x DATE` (`os.date`), `replace_line`. If
  `AUTO_ARCHIVE=1`, `bin/todo.sh` re-invokes `archive` (overridable via
  `libexec/`, mirroring `"$TODO_FULL_SH" archive`).
  Tests: `tests/cli_do.posix.sh` — single, multi `2,3` + space-separated,
  already-done exit 1, archive hook on/off, verbose output lines.
- [ ] `del` / `rm` (`lua`). No-TERM path uses `confirm` (forced in tests).
  TERM path ports the five-pattern strip chain as an ordered `gsub` sequence
  on the task text (not sed). `PRESERVE_LINE_NUMBERS=0` deletes the line,
  else blanks it. Die `not found` when text is unchanged.
  Tests: `tests/cli_del.posix.sh` — both modes, term-strip, missing-term die,
  numbering stability.
- [ ] `pri` / `p` (`lua`). Pairwise `NR PRI` args, `[A-Z]` validation (die +
  usage), strip old pri, prepend new. Three message variants (re-prioritized /
  prioritized / already + exit 1).
  Tests: `tests/cli_pri.posix.sh` — set, change, same-pri exit 1, bad-pri die,
  multi-pair.
- [ ] `depri` / `dp` (`lua`). Comma-or-space split, strip `^(.) ` when present,
  else stderr `not prioritized` + exit 1.
  Tests: `tests/cli_depri.posix.sh` — single, `1,2,3`, unprioritized exit 1.
- [ ] `append` / `app` (`lua`). Fetch line via `store.get_line`;
  `SENTENCE_DELIMITERS` (`,.:;`, from env with default in `todorc.sample`)
  decides the joining space; `replace_line`.
  Tests: `tests/cli_append.posix.sh` — normal, delimiter-leading (`, foo`),
  missing-item die.
- [ ] `prepend` / `prep` + `replace` (`lua` new module `prepd.lua`). Pri+date
  prefix extraction via `task.parse` (replaces the `priAndDateExpr` sed);
  strip, reattach, join (prepend appends `" " .. old`). `clean_add` only —
  Lua needs no `for sed` escaping variant (no separator problem). `replace`
  additionally adopts a replacement-supplied pri/date over the original.
  Tests: `tests/cli_prepend_replace.posix.sh` — pri/date preserved both ways,
  replacement pri/date override, verbose outputs.
- [ ] `move` / `mv` (`lua` + `sh` paths). `src` defaults to `TODO_FILE`; both
  files must exist (die otherwise). `confirm`, blank-or-delete per preserve
  mode, append to dest with EOL fix, dual-prefix verbose message
  (`SRC: N moved to M in DEST`).
  Tests: `tests/cli_move.posix.sh` — default src, explicit src, missing
  src/dest dies, line-number preservation.

## Phase 3 — lists and reports (`awk` stages + `sh` pipes; `lua` for date math)

- [ ] `listall` / `lsa` (`awk` + `sh`). New `listall.awk`: numbers every line
  including blanks; `TOTAL`/`PADDING` via `-v`, over-long numbers become 0
  (legacy post-filter awk parity). `sh` runs the pipe twice (todo + done,
  `VERBOSE=0`) plus the 3-line footer (`TODO:` / `DONE:` / `total` counts).
  Tests: `tests/cli_listall.posix.sh` — dual counts, blank numbering,
  filtered counts.
- [ ] `listcon` / `lsc`, `listproj` / `lsprj` (`awk` + `sh`). Extend
  `contexts.awk`/`projects.awk` with sigil-pattern env (`BEFORE/VALID/AFTER`,
  defaulting to legacy semantics) + `sort -u` stage in the pipe.
  Tests: `tests/unit_sigils.posix.sh` + transcript entries in list suite.
- [ ] `listpri` / `lsp` (`sh` + `awk`). `sh` validates the pri arg
  (`[A-Za-z]` single/range or default `A-Z`, uppercased via `tr`), passes
  `PRI_RANGE` to new `filter_pri.awk` (matches `^NUM (P) `), reuses list pipe.
  Tests: `tests/cli_listpri.posix.sh` — single, range `A-C`, default, invalid.
- [ ] `report` (`sh`; no `lua` — no task semantics involved). Re-exec
  `archive` first, count both files (`awk 'END{print NR}'`), compare with the
  last `report.txt` line, append a `date +%Y-%m-%dT%T` stamp or print the
  up-to-date message.
  Tests: `tests/cli_report.posix.sh` — update path, up-to-date path, empty
  files.
- [ ] `listaddons` (pure `sh`: enumerate `libexec/`, file-or-dir exec check,
  count + footer, die when empty/missing).
  Tests: `tests/cli_listaddons.posix.sh` with a fixture `libexec` sandbox.
- [ ] `shorthelp` (`sh` static text + transcript; plain stdout, no pager/TTY
  detection — see Decisions).

## Phase 4 — maintenance and compat

- [ ] `archive` (`sh` + `awk`, then `c99`). `archive.awk` selects `^x ` lines
  → append to done → remove from todo (blank-defrag per preserve mode). Wire
  in `src/todo_norm --pipe` + a Lua/awk-vs-C differential test (extend
  `unit_todo_norm.posix.sh` with an archive corpus).
  Tests: `tests/cli_archive.posix.sh` — moves, empty-archive message, verbose.
- [ ] `deduplicate` (`awk`). Replace the 10-line hold-space sed with
  `dedupe.awk` (first occurrence wins; preserve mode blanks instead of
  deleting) + before/after non-blank counts + `No duplicate tasks found` die.
  No C port unless profiling demands it.
  Tests: `tests/cli_dedupe.posix.sh` — both preserve modes, no-dup die, counts.
- [ ] `command` + `TODOTXT_DEFAULT_ACTION` (`sh`). `command` strips arg 0 and
  re-dispatches through `bin/todo.sh` with a loop-depth guard (die on
  recursion); default action re-execs similarly when no builtin/addon matches.
  Tests: `tests/cli_command.posix.sh` — nested `command list`,
  default-action fallback, recursion guard trips.
- [ ] Completion: dropped (see Decisions). No code, no tests — one-line record
  that `todo_completion` stays a Bash-only legacy artifact.
- [ ] Colorization (`awk`). Extend `colorize.awk` with POSIX-only `ENVIRON`
  reads (`PRI_A/B/C/X`, project/context/date/number/meta word classes per
  legacy lines 978–1033). Property test: with empty color env, output is
  byte-identical to `format.awk`.
  Tests: `tests/unit_colorize.posix.sh` — pri classes, word classes, plain
  identity.

## Phase 5 — parity and merge endgame

- [ ] Full-matrix green: every legacy `tNNNN` behaviour has a POSIX transcript
- [ ] Legacy-vs-POSIX differential run over a shared fixture corpus (incl.
  CRLF, whitespace runs, multibyte text)
- [ ] `Makefile.posix` `disttest` equivalent (stamp VERSION into a `dist/`
  tree, rerun suite)
- [ ] Squash-merge feature into `master` (`master` diverges from upstream at
  this point; syncs switch from `--ff-only` to merge — `docs/upstream-sync.txt`)

## Standing

- [ ] Check `git ls-remote upstream master` each session; port fixes per rule
- [ ] Keep `AGENTS.md` and `docs/` in step with every port commit

## Decisions (recorded, do not relitigate without cause)

- `todo_completion` (Bash `complete` builtin) is not portable: dropped, stays
  legacy-only. No POSIX completion will be written.
- `help`/`shorthelp` print to plain stdout: no `$PAGER`, no TTY detection
  (`command -v` is banned anyway; `type` would allow it, but test-friendly
  plain output wins).
- Upstream sync is consume-only; `master` stays a pristine mirror until the
  Phase 5 merge. Full procedure: `docs/upstream-sync.txt`.
