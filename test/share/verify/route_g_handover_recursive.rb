def m(n)
  y = +"a"
  return y if n == 0
  z = m(n - 1)
  @last = z
  z
end
r = m(2)
r << "!"
p @last
