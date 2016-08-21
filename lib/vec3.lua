local mt, fn = {}, {}

local function vec3(x, y, z)
  assert(type(x)=="number" and type(y)=="number" and type(z)=="number", "Expected number, number, number")
  return setmetatable({x=x, y=y, z=z}, mt)
end

function mt:__index(key)
  -- Swizzling
  if key:find("^[xyz][xyz][xyz]$") then
    return vec3(self[key:sub(1,1)], self[key:sub(2,2)], self[key:sub(3,3)])
  end
  if vec2 and key:find("^[xyz][xyz]$") then
    return vec2(self[key:sub(1,1)], self[key:sub(2,2)])
  end
  return fn[key]
end

function mt:__tostring()
  return "["..self.x..", "..self.y..", "..self.z.."]"
end

function mt:__add(v)
  if type(self)~="table" or getmetatable(self)~=mt then
    self, v = v, self
  end
  assert(type(v)=="table" and getmetatable(v)==mt, "Attempt to perform arithmetic on vec3 and "..type(v))
  return vec3(self.x+v.x, self.y+v.y, self.z+v.z)
end

function mt:__sub(v)
  if type(self)~="table" or getmetatable(self)~=mt then
    self, v = v, self
  end
  assert(type(v)=="table" and getmetatable(v)==mt, "Attempt to perform arithmetic on vec3 and "..type(v))
  return vec3(self.x-v.x, self.y-v.y, self.z-v.z)
end

function mt:__mul(v)
  if type(self)~="table" or getmetatable(self)~=mt then
    self, v = v, self
  end
  assert(type(v)=="number", "Attempt to perform arithmetic on vec3 and "..type(v))
  return vec3(self.x*v, self.y*v, self.z*v)
end

function mt:__div(v)
  if type(self)~="table" or getmetatable(self)~=mt then
    self, v = v, self
  end
  assert(type(v)=="number", "Attempt to perform arithmetic on vec3 and "..type(v))
  return vec3(self.x/v, self.y/v, self.z/v)
end

function fn:abs()
  return vec3(math.abs(self.x), math.abs(self.y), math.abs(self.z))
end

function fn:max(...)
  return vec3(math.max(self.x, ...), math.max(self.y, ...), math.max(self.z, ...))
end

function fn:min(...)
  return vec3(math.min(self.x, ...), math.min(self.y, ...), math.min(self.z, ...))
end

function fn:length()
  return math.sqrt(self.x^2+self.y^2+self.z^2)
end

function fn:dot(v)
  assert(type(v)=="table" and getmetatable(v)==mt, "Attempt to perform arithmetic on vec3 and "..type(v))
  return self.x*v.x + self.y*v.y + self.z*v.z
end

function fn:normalized()
  return self/self:length()
end

return vec3