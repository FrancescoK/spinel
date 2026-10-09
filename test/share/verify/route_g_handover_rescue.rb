def m
  y = +"a"
  raise "x"
rescue
  @k = y
  y
end
r = m
r << "!"
p @k
