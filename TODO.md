# Remaining Work (TODO)

This file lists remaining tasks to finish the full hardening, test, and release workflow for the todo.txt-cli rewrite.

- [ ] Expand unit tests (Check): add tests for parsing edge cases, `mark_done` boundary conditions, `generate_report` content checks, concurrency/file-io error injection.
- [ ] Harden code for SEI CERT C compliance: avoid implicit conversions, tighten buffer usage, return explicit error codes, add more static asserts where applicable.
- [ ] Implement platform abstraction layer (`include/todo/platform.h` + `src/platform.c`) for atomic file replace, secure temp files and UCRT/POSIX differences.
- [ ] Integrate `clang-tidy` (opt-in via `-DENABLE_CLANG_TIDY=ON`) and resolve reported issues; add CI-style checks locally.
- [ ] Improve `clang-format` rules and run formatting across codebase; commit style fixes.
- [ ] Replace simple `temp.txt` replacement with atomic, secure replacements (use platform APIs where available).
- [ ] Improve `scripts/run_profile_workload.lua` to use deterministic fixtures and support warmup iterations for BOLT profiling.
- [ ] Add `llvm-bolt` integration for Release packaging; create documented `profile-build`, `run-profile`, and `bolt-opt` targets and test locally.
- [ ] Create reproducible packaging: include `LICENSE`, `AGENTS.md`, `README.md`, templates and create reproducible `.tar.gz` with stable timestamps.
- [ ] Add thorough documentation to `AGENTS.md` describing tool versions, local install steps for mingw-clang-ucrt, LuaJIT, Check, BOLT and how to run the profiling workflow.
- [ ] Optional: add `--config` and `--data-dir` CLI flags with documented precedence (CLI flags > env vars > defaults).
- [ ] Run static analysis (`cppcheck`, `clang-tidy`) and address all high/critical results.
- [ ] Final QA: run Test build with sanitizers, fix all sanitizer issues, run full test-suite and create final Release package.

Notes:
- Test builds use dynamic linking to allow sanitizers; Release builds attempt static binary for distribution.
- Lua scripts were added and are expected to run via `luajit` or `lua` in PATH; CMake will enable generation targets only if a runnable Lua is found.
