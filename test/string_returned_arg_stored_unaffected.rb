# Stored calls the returned-argument route leaves alone.

def id(x) = x
def cp(x) = x.dup
def norm(x) = x.empty? ? "-" : x

# nothing is mutated in place
u = +"u"
q = []
q << id(u)
p q, u

# the method answers a fresh String
w = +"w"
r = [cp(w)]
w << "z"
p r, w
h = { k: cp(w) }
h[:k] << "y"
p h[:k], w

# the variable is given another String, which is no mutation
t = +"t"
a = [id(t)]
t = t + "z"
p a, t

# a literal that is not kept is read where it stands
line = +""
line << "abc"
puts [norm(line), "x"].join(",")

# the Array is never read
m = +"m"
o = []
o << id(m)
m << "z"
p m
