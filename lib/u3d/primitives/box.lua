return {
  distance = function(pos, size)
    local d = pos:abs() - size
    return math.min(math.max(d.x, d.y, d.z), 0) + d:max(0):length()
  end,
  normal = function(pos, size)
    return vec3(1, 0, 0)
  end,
}