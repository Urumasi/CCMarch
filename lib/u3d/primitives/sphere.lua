return {
  distance = function(pos, r)
    return pos:length()-r
  end,
  normal = function(pos, r)
    return pos:normalized()
  end,
}