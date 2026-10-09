x = nil; i = 0
s = +"abc"
while i < 1
  x = s; i += 1
end
s << "!"
p(x)
p s
