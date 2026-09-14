-- task.lua - canonical todo.txt line model (Lua-core authority).
-- Parses: [(PRI)] [YYYY-MM-DD] text +proj @ctx key:val ; done lines: x DATE text
assert(_VERSION == "Lua 5.5", "need Lua 5.5, got " .. tostring(_VERSION))
local task = {}
function task.parse(line)
  line = line:gsub("\r", "")
  local t = { raw = line, done = false, pri = nil, date = nil, text = line }
  local done, rest = line:match("^x%s+(.*)$")
  if done then t.done = true; line = done end
  local pri, rest2 = line:match("^%(([A-Z])%)%s+(.*)$")
  if pri then t.pri = pri; line = rest2 end
  local d, rest3 = line:match("^(%d%d%d%d%-%d%d%-%d%d)%s+(.*)$")
  if d then t.date = d; line = rest3 end
  t.text = line
  return t
end
function task.format(t)
  local s = ""
  if t.done then s = s .. "x " end
  if t.pri then s = s .. "(" .. t.pri .. ") " end
  if t.date then s = s .. t.date .. " " end
  return s .. (t.text or "")
end
function task.projects(text)
  local out = {}
  for w in text:gmatch("%S+") do
    if w:sub(1, 1) == "+" and #w > 1 then out[#out + 1] = w:sub(2) end
  end
  return out
end
function task.contexts(text)
  local out = {}
  for w in text:gmatch("%S+") do
    if w:sub(1, 1) == "@" and #w > 1 then out[#out + 1] = w:sub(2) end
  end
  return out
end
return task
