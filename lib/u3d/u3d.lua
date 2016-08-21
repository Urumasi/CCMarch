local vec2 = require "vec2"
local vec3 = require "vec3"

local u3d = {}

do -- Colors
  local palette = require "u3d/colors"

  function u3d.getColor(clr, int)
    if not palette[clr] then return nil end
    return palette[clr][math.floor((1-int)*#palette[clr])+1] or colors.black
  end
end

do -- Objects
  local obj = {}

  local list = fs.list("lib/u3d/primitives")
  for k, v in ipairs(list) do
    if v:sub(-4, -1)==".lua" then
      v = v:sub(1, -5)
    end
    obj[v] = require("u3d/primitives/"..v)
    u3d["new"..v:sub(1,1):upper()..v:sub(2)] = function(...)
      return setmetatable({args={...}}, {__index = obj[v]})
    end
  end

  function u3d.isObject(o)
    for k, v in pairs(obj) do
      if v.distance==o.distance then
        return k
      end
    end
    return nil
  end
end

do -- Environment
  local mt, fn = {}, {}
  mt.__index = fn

  local _yieldCounter = 0
  local function _tryYield()
    _yieldCounter = _yieldCounter+1
    if _yieldCounter>100 then
      sleep(0.1)
      _yieldCounter = 0
    end
  end

  local function _step(env, pos, dir)
    local newpos = pos.xyz+dir*env.step
    if #env.objects==0 then
      return nil, nil, newpos, nil
    end
    local closestObject, distance, normal
    for k, v in pairs(env.objects) do
      local dist = v.distance(newpos, unpack(v.args))
      if distance==nil or dist<distance then
        distance = dist
        normal = v.normal(newpos, unpack(v.args))
        closestObject = v
      end
    end
    return closestObject, distance, newpos, normal
  end

  function fn:add(obj)
    if u3d.isObject(obj) then
      table.insert(self.objects, obj)
    else
      error(tostring(obj).." is not an object!", 2)
    end
  end

  function fn:render(zoom, distance, context)
    local context = context or term
    local w, h = context.getSize()
    for y=0, h-1 do
      context.setCursorPos(1, y+1)
      for x=0, w-1 do
        local hit = false
        local pos = vec3(distance, (x*2-w+1)*1.5*zoom/w, (y*2-h+1)*zoom/h)
        local dir = vec3(-1, 0, 0)
        local obj, dist, norm
        for i=1, self.maxsteps do
          obj, dist, pos, norm = _step(self, pos, dir)
          if dist<self.step then
            hit = true
            local dot = norm:dot(self.lightdir)
            context.setBackgroundColor(u3d.getColor("green", (dot+0.5)/1.5))
          end
        end
        if not hit then context.setBackgroundColor(colors.black) end
        context.write(" ")
        _tryYield()
      end
    end
  end

  function u3d.createEnvironment()
    return setmetatable({
      step = 0.1,
      maxsteps = 1000,
      objects = {},
      lightdir = vec3(-1,-1,-1):normalized(),
    }, mt)
  end
end

return u3d