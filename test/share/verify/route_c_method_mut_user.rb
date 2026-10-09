s = +"abc"
t = s
def mut(x) = x << "!"; method(:mut).call(s)
p s
p t
