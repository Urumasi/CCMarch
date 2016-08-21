local vec2 = require "vec2"
local vec3 = require "vec3"

local u3d = {}

do -- Colors
  local palette = require "u3d/colors"

  function u3d.getColor(clr, int)
    if not palette.colors[clr] then return nil end
    local num = (1-int)*#palette.colors[clr]
    local bg = palette.colors[clr][math.floor(num)+1] or colors.black
    local fg = palette.colors[clr][math.ceil(num)+1] or colors.black
    local frac = num%1 * 2
    if frac>1 then
      frac = 2-frac
      bg, fg = fg, bg
    end
    local ch = palette.chars[math.floor(frac*#palette.chars)+1]
    return fg, bg, ch
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
    if _yieldCounter>1000 then
      os.queueEvent("fake")
      os.pullEvent("fake")
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

    local dir = vec3(-1, 0, 0)--vec3(-1, -1, -0.7):normalized()

    for y=0, h-1 do
      context.setCursorPos(1, y+1)
      for x=0, w-1 do
        local hit = false
        local pos = vec3(distance, (x*2-w+1)*zoom/h/1.5, (y*2-h+1)*zoom/h)
        local obj, dist, norm
        local ch = " "
        for i=1, self.maxsteps do
          obj, dist, pos, norm = _step(self, pos, dir)
          if dist<self.step then
            hit = true
            local dot = norm:dot(self.lightdir)
            local fg, bg, _ch = u3d.getColor("green", (dot+0.5)/1.5)
            context.setTextColor(fg)
            context.setBackgroundColor(bg)
            ch = _ch
            break
          end
          if i%200==0 then
            os.queueEvent("fake")
            os.pullEvent("fake")
          end
        end
        if not hit then context.setBackgroundColor(colors.black) end
        context.write(ch)
      end
    end
  end

  function u3d.createEnvironment()
    return setmetatable({
      step = 0.1,
      maxsteps = 1000,
      objects = {},
      lightdir = vec3(1,-1,-1):normalized(),
    }, mt)
  end
end

return u3d