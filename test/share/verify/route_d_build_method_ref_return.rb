def id(x) = x
m = method(:id)
s = +"abc"
t = m.call(s)
t << "!"
p s
