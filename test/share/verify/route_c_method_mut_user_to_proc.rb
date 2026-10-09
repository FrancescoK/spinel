s = +"abc"
t = s
def mut(x) = x << "!"; [s].each(&method(:mut))
p s
p t
