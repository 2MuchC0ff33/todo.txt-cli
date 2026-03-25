-- Simple AGENTS.md generator in Lua
local ok, lfs = pcall(require, 'lfs')
if not ok then
  -- minimal lfs fallback for listing tests
  lfs = {}
  lfs.dir = function(path)
    local p = io.popen('cmd /C dir /B "'..path..'" 2>nul')
    if not p then return function() return nil end end
    local t = {}
    for f in p:lines() do t[#t+1] = f end
    p:close()
    local i = 0
    return function()
      i = i + 1
      return t[i]
    end
  end
end
local cmake = 'CMakeLists.txt'
local out = 'AGENTS.md'

local function read_file(path)
  local f = io.open(path, 'r')
  if not f then return nil end
  local c = f:read('*a')
  f:close()
  return c
end

local function list_tests()
  local tests = {}
  for file in lfs.dir('tests') do
    if file:match('%.c$') then tests[#tests+1] = file end
  end
  table.sort(tests)
  return tests
end

local cm = read_file(cmake) or ''
local tests = list_tests()

local content = {}
content[#content+1] = '# AGENTS & Build Instructions\n'
content[#content+1] = 'Local build (Release): `cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build build`\n'
content[#content+1] = '\nTest build (sanitizers): `cmake -S . -B build-test -G Ninja -DCMAKE_BUILD_TYPE=Test && cmake --build build-test`\n'
content[#content+1] = '\nDetected test sources:\n'
for _,t in ipairs(tests) do content[#content+1] = '- '..t..'\n' end

local f = io.open(out, 'w')
f:write(table.concat(content))
f:close()
print('Wrote '..out)
