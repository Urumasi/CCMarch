local mt, fn = {}, {}

local function vec2(x, y)
  assert(type(x)=="number" and type(y)=="number", "Expected number, number")
  return setmetatable({x=x, y=y}, mt)
end

function mt:__index(key)
  -- Swizzling
  if key:find("^[xy][xy]$") then
    return vec2(self[key:sub(1,1)], self[key:sub(2,2)])
  end
  if vec3 and key:find("^[xy][xy][xy]$") then
    return vec3(self[key:sub(1,1)], self[key:sub(2,2)], self[key:sub(3,3)])
  end
  return fn[key]
end

function mt:__tostring()
  return "["..self.x..", "..self.y.."]"
end

function mt:__add(v)
  if type(self)~="table" or getmetatable(self)~=mt then
    self, v = v, self
  end
  assert(type(v)=="table" and getmetatable(v)==mt, "Attempt to perform arithmetic on vec2 and "..type(v))
  return vec2(self.x+v.x, self.y+v.y)
end

function mt:__sub(v)
  if type(self)~="table" or getmetatable(self)~=mt then
    self, v = v, self
  end
  assert(type(v)=="table" and getmetatable(v)==mt, "Attempt to perform arithmetic on vec2 and "..type(v))
  return vec2(self.x-v.x, self.y-v.y)
end

function mt:__mul(v)
  if type(self)~="table" or getmetatable(self)~=mt then
    self, v = v, self
  end
  assert(type(v)=="number", "Attempt to perform arithmetic on vec2 and "..type(v))
  return vec2(self.x*v, self.y*v)
end

function mt:__div(v)
  if type(self)~="table" or getmetatable(self)~=mt then
    self, v = v, self
  end
  assert(type(v)=="number", "Attempt to perform arithmetic on vec2 and "..type(v))
  return vec2(self.x/v, self.y/v)
end

function fn:length()
  return math.sqrt(self.x^2+self.y^2)
end

function fn:normalized()
  return self/self:length()
end

return vec2