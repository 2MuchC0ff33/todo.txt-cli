-- store.lua - file transitions (read/write/append/replace line N).
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
function store.write_lines(path, lines)
  local fh, err = io.open(path, "w")
  if not fh then io.stderr:write("store: " .. tostring(err) .. "\n"); os.exit(1) end
  for i = 1, #lines do fh:write(lines[i], "\n") end
  fh:close()
end
function store.append_line(path, line)
  local fh, err = io.open(path, "a")
  if not fh then io.stderr:write("store: " .. tostring(err) .. "\n"); os.exit(1) end
  fh:write(line, "\n")
  fh:close()
end
return store
