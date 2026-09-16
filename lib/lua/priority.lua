-- priority.lua - priority helpers (Lua-core).
assert(_VERSION == "Lua 5.5", "need Lua 5.5, got " .. tostring(_VERSION))
local priority = {}
function priority.upper(line)
  return line:gsub("^%((%l)%)", function(c) return "(" .. c:upper() .. ")" end, 1)
end
function priority.strip(line)
  return line:gsub("^%([A-Z]%)%s+", "", 1)
end
function priority.set(line, pri)
  line = priority.strip(line)
  if pri and pri ~= "" then return "(" .. pri .. ") " .. line end
  return line
end
return priority
