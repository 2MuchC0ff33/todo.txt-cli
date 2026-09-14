-- input.lua - cleaninput / fixMissingEndOfLine ports (Lua-core).
assert(_VERSION == "Lua 5.5", "need Lua 5.5, got " .. tostring(_VERSION))
local input = {}
function input.clean(s)
  s = s:gsub("\r", "")
  s = s:match("^%s*(.-)%s*$") or ""
  s = s:gsub("%s+", " ")
  return s
end
-- clean_add mirrors legacy cleaninput: CR/LF become single spaces, kept as-is.
function input.clean_add(s)
  s = s:gsub("\r", " ")
  s = s:gsub("\n", " ")
  return s
end
-- upper_leading mirrors legacy uppercasePriority: ^(x) -> ^(X).
function input.upper_leading(s)
  return s:gsub("^%((%l)%)", function(c) return "(" .. c:upper() .. ")" end, 1)
end
return input
