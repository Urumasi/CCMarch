return {
  distance = function(pos, size)
    local d = pos:abs() - size
    return math.min(math.max(d.x, d.y, d.z), 0) + d:max(0):length()
  end,
  normal = function(pos, size)
    local a = pos:abs()
    if a.x>=a.y and a.x>=a.z then
      return vec3(math.sign(pos.x), 0, 0)
    end
    if a.x>=a.y and a.x>=a.z then
      return vec3(0, math.sign(pos.y), 0)
    end
    return vec3(0, 0, math.sign(pos.z))
  end,
}