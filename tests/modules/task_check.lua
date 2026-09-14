-- tests/modules/task_check.lua - verify task.lua parse/format round-trip.
assert(_VERSION == "Lua 5.5", "need Lua 5.5, got " .. tostring(_VERSION))
local path = arg[1]
package.path = package.path .. ";lib/lua/?.lua"
local task = dofile("lib/lua/task.lua")
local fh = io.open(path, "r")
if not fh then io.stderr:write("cannot open\n"); os.exit(1) end
local n = 0
for line in fh:lines() do
  n = n + 1
  local t = task.parse(line)
  io.write(task.format(t), "\n")
end
fh:close()
if n ~= 3 then io.stderr:write("expected 3 lines\n"); os.exit(1) end
