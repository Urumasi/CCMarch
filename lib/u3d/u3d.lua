local vec2 = require "vec2"
local vec3 = require "vec3"

local u3d = {}

do -- Objects
  print(shell.dir())
  --local list = fs.list()
end

do -- Environment
  local mt, fn = {}, {}
  mt.__index = fn

  function u3d.createEnvironment()
    return setmetatable({
      objects = {},
    }, mt)
  end
end

return u3d