def keep(x) = (@k = x)
def fwd(*) = keep(*)
s = +"abc"
fwd(s); r = @k
r << "!"
p s
p r
