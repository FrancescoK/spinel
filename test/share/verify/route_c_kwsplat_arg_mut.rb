s = +"abc"
t = s
def f(**kw) = kw[:x] << "!"; f(**{x: s})
p s
p t
