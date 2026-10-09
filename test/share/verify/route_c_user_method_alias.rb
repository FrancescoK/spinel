s = +"abc"
t = s
def mut(x) = x << "!"; alias mut2 mut; mut2(s)
p s
p t
