def m
  y = +"a"
  @keep = proc { y }
  y
end
r = m
r << "!"
p @keep.call
