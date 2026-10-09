def keep(x) = (@k = x)
s = +"abc"
[s].each(&method(:keep)); r = @k
r << "!"
p s
p r
