# AGENTS

Local build (Release):
```
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```

Test build (sanitizers):
```
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Test
cmake --build build
```

Lint/format (if installed):
```
cmake --build build --target format
cmake --build build --target cppcheck
```

Profile workload (local):
```
luajit scripts/run_profile_workload.lua build/todo.exe
```

Notes:
- Tests are built if the Check testing framework is available on the system.
- Lua-based scripts require a working `lua` or `luajit` in PATH.
