-- date.lua - date helpers (epoch via os.time; format via os.date).
assert(_VERSION == "Lua 5.5", "need Lua 5.5, got " .. tostring(_VERSION))
local date = {}
function date.today()
  return os.date("%Y-%m-%d")
end
function date.valid(s)
  if not s:match("^%d%d%d%d%-%d%d%-%d%d$") then return false end
  return true
end
return date
