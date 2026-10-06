# choose answers one of its two arguments, so t is s itself when the flag
# is false, and an append through t changes s. The first argument, a fresh
# String, does not hide the second: refused, as `t = id(s)` is.
def choose(x, y, f) = f ? x : y
s = +"abc"
t = choose(+"unused", s, false)
t << "!"
p s
