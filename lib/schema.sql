-- lib/schema.sql - sqlite3 schema for the POSIX-OS rewrite (DB-truth store).
-- Applied by lib/sh/sqlite.sh db_init (sh owns all sqlite3 invocations).
-- lines: one row per physical line of a tracked file (byte-faithful layout).
--   file   = basename of the file within TODO_DIR (todo.txt, done.txt, addto dests)
--   id     = 1-indexed physical line number within that file
--   kind   = 'task' (non-blank) | 'blank' (empty line, preserved)
--   text   = verbatim line content (blank rows: '')
--   status = 'todo' | 'done' (derived from a leading "x " prefix on import)
--   done_date = completion date when status='done' (else NULL)
--   archived  = 1 once moved to done.txt by archive (future phase)
-- meta: cksum reconcile state (key 'cksum:<file>' = last-synced `cksum` output).
PRAGMA journal_mode=WAL;
CREATE TABLE IF NOT EXISTS lines (
  file TEXT NOT NULL,
  id INTEGER NOT NULL,
  kind TEXT NOT NULL CHECK(kind IN ('task','blank')),
  text TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'todo' CHECK(status IN ('todo','done')),
  done_date TEXT,
  archived INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (file, id)
);
CREATE TABLE IF NOT EXISTS meta (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);