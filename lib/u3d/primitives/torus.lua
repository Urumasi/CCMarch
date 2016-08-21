return {
  distance = function(pos, t)
    local q = vec2(pos.xz:length()-t.x, p.y)
    return q:length()-t.y
  end,
  normal = function(pos, t)
    return vec3(1, 0, 0)
  end,
}