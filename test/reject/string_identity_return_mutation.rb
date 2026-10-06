# A method that returns its parameter hands back the caller's String, so the
# result and the variable passed in are one object. The result is a copy
# today, and the append through it would be lost: refused.
def id(x) = x
s = +"a"
t = id(s)
t << "!"
p s
