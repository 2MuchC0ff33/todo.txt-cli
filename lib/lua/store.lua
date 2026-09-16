-- store.lua - file transitions (read + apply-record emission; DB-truth).
-- Reads operate on the synced export file; mutations are emitted as
-- `apply|append|<file>|<text>` records that sh applies to sqlite3 and
-- re-exports. Lua never writes files and never shells out.
assert(_VERSION == "Lua 5.5", "need Lua 5.5, got " .. tostring(_VERSION))
local store = {}
function store.read_lines(path)
  local lines = {}
  local fh = io.open(path, "r")
  if not fh then return lines end
  for line in fh:lines() do lines[#lines + 1] = line:gsub("\r", "") end
  fh:close()
  return lines
end
function store.apply_append(file, text)
  io.write("apply|append|" .. file .. "|" .. text .. "\n")
end
return store