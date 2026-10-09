def m(x)
  y = +"a"
  x << "!"
  y
end
q = +"q"
r = m(q)
r << "?"
p r, q
