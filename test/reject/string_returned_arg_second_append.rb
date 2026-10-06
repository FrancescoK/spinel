# The same through the call's value itself: choose answers s when the flag
# is false, so the append changes s. Refused, as `id(s) << "!"` is.
def choose(x, y, f) = f ? x : y
s = +"abc"
choose(+"unused", s, false) << "!"
p s
