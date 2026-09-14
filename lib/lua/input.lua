-- input.lua - cleaninput / fixMissingEndOfLine ports (Lua-core).
assert(_VERSION == "Lua 5.5", "need Lua 5.5, got " .. tostring(_VERSION))
local input = {}
function input.clean(s)
  s = s:gsub("\r", "")
  s = s:match("^%s*(.-)%s*$") or ""
  s = s:gsub("%s+", " ")
  return s
end
return input
