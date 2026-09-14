-- actions.lua - CLI action dispatch (Lua-core). Usage: lua actions.lua ACTION [args...]
assert(_VERSION == "Lua 5.5", "need Lua 5.5, got " .. tostring(_VERSION))
local action = arg[1] or ""
if action == "" or action == "help" or action == "-h" then
  io.write("Usage: todo.sh action [args...]\n")
  os.exit(0)
end
io.stderr:write("todo: action '" .. action .. "' not yet ported (scaffold)\n")
os.exit(2)
