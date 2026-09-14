-- config.lua - config validation (Lua-core).
assert(_VERSION == "Lua 5.5", "need Lua 5.5, got " .. tostring(_VERSION))
local config = {}
function config.require(var, name)
  if not var or var == "" then
    io.stderr:write("config: " .. name .. " unset\n")
    os.exit(1)
  end
  return var
end
return config
