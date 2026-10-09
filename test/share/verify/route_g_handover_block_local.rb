def m
  y = +"a"
  [1].each { @k = y }
  y
end
r = m
r << "!"
p @k
