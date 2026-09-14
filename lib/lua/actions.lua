-- actions.lua - add/addm/addto dispatch (Lua-core domain logic).
-- Usage: lua actions.lua ACTION [args...]
-- Env: TODO_DIR TODO_FILE DONE_FILE REPORT_FILE TODOTXT_VERBOSE TODOTXT_FORCE
--      TODOTXT_DATE_ON_ADD TODOTXT_PRIORITY_ON_ADD
-- Host (sh) sets env, owns pipes; Lua owns task semantics. No shell-outs.
assert(_VERSION == "Lua 5.5", "need Lua 5.5, got " .. tostring(_VERSION))

local function script_dir()
  local s = arg[0] or "."
  local last = 0
  for i = 1, #s do
    local c = s:sub(i, i)
    if c == "/" or c == "\\" then last = i end
  end
  if last == 0 then return "." end
  return s:sub(1, last - 1)
end

local base = script_dir()
local input = dofile(base .. "/input.lua")
local store = dofile(base .. "/store.lua")

local function getenv_num(name, def)
  local v = os.getenv(name)
  if v == nil or v == "" then return def end
  return tonumber(v) or def
end

local TODO_DIR = os.getenv("TODO_DIR") or ""
local TODO_FILE = os.getenv("TODO_FILE") or ""
local VERBOSE = getenv_num("TODOTXT_VERBOSE", 1)
local FORCE = getenv_num("TODOTXT_FORCE", 0)
local DATE_ON_ADD = os.getenv("TODOTXT_DATE_ON_ADD") or "0"
local PRI_ON_ADD = os.getenv("TODOTXT_PRIORITY_ON_ADD") or ""

local function die(msg)
  io.stderr:write(msg .. "\n")
  os.exit(1)
end

local function prefix_of(path)
  local name = path:match("([^/\\]+)$") or path
  name = name:gsub("%..*$", "")
  return name:upper()
end

local function fix_eol(path)
  local fh = io.open(path, "r")
  if not fh then return end
  local data = fh:read("*a")
  fh:close()
  if data ~= "" and data:sub(-1) ~= "\n" then
    local out = io.open(path, "a")
    if out then out:write("\n"); out:close() end
  end
end

local function line_count(path)
  local fh = io.open(path, "r")
  if not fh then return 0 end
  local n = 0
  for _ in fh:lines() do n = n + 1 end
  fh:close()
  return n
end

local function decorate(text)
  text = input.upper_leading(text)
  if DATE_ON_ADD == "1" then
    local today = os.date("%Y-%m-%d")
    local pri = text:match("^(%([A-Z]%) )")
    if pri then
      text = pri .. today .. " " .. text:sub(#pri + 1)
    else
      text = today .. " " .. text
    end
  end
  if PRI_ON_ADD ~= "" and not text:match("^%([A-Z]%)") then
    text = "(" .. PRI_ON_ADD .. ") " .. text
  end
  return text
end

local function add_one(path, raw)
  local text = decorate(input.clean_add(raw))
  fix_eol(path)
  store.append_line(path, text)
  if VERBOSE > 0 then
    local num = line_count(path)
    io.write(num .. " " .. text .. "\n")
    io.write(prefix_of(path) .. ": " .. num .. " added.\n")
  end
end

local function join_args(from)
  local parts = {}
  for i = from, #arg do parts[#parts + 1] = arg[i] end
  return table.concat(parts, " ")
end

local action = (arg[1] or ""):lower()

if action == "add" or action == "a" then
  if TODO_FILE == "" then die("TODO: TODO_FILE unset.") end
  local text = join_args(2)
  if text == "" and FORCE == 0 then
    io.stderr:write("Add: ")
    text = io.read("*l") or ""
  end
  if text == "" then die('usage: todo.sh add "TODO ITEM"') end
  add_one(TODO_FILE, text)
elseif action == "addm" then
  if TODO_FILE == "" then die("TODO: TODO_FILE unset.") end
  local text = join_args(2)
  if text == "" and FORCE == 0 then
    io.stderr:write("Add: ")
    text = io.read("*l") or ""
  end
  if text == "" then die('usage: todo.sh addm "TODO ITEMS"') end
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    if line ~= "" then add_one(TODO_FILE, line) end
  end
elseif action == "addto" then
  local dest = arg[2] or ""
  local text = join_args(3)
  if dest == "" or text == "" then die('usage: todo.sh addto DEST "TODO ITEM"') end
  local path = TODO_DIR .. "/" .. dest
  local probe = io.open(path, "r")
  if not probe then die("TODO: Destination file " .. path .. " does not exist.") end
  probe:close()
  add_one(path, text)
else
  if action == "" then die("usage: todo.sh action [args...]") end
  die("TODO: Unknown action '" .. action .. "'.")
end
