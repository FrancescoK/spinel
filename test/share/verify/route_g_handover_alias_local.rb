def m
  y = +"a"
  w = y
  @w = w if false
  y
end
r = m
r << "!"
p r
