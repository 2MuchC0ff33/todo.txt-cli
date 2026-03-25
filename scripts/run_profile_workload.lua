-- Simple workload runner to exercise todo commands for profiling
local args = {...}
local bin = args[1] or './build/todo.exe'
local tmp = 'profile_fixtures.txt'

local function run(cmd)
  print('RUN: '..cmd)
  local res = os.execute(cmd)
  if res ~= 0 then print('Command failed: '..cmd) end
end

-- create some sample workload
for i=1,100 do
  run(string.format('%s add "task %d"', bin, i))
end

run(bin..' list')
for i=1,50 do
  run(string.format('%s done %d', bin, i))
end
run(bin..' report')

print('Profile workload completed')
