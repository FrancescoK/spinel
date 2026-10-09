def id(x) = x
s = +"abc"
t = [s].map(&method(:id)).first
t << "!"
p s
