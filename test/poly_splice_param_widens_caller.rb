# `arr[i, n] = src` through a parameter stores src's elements into the
# caller's own array. An element the caller's array kind cannot hold widens
# that array where it is built; a promoted copy left the caller's array as it
# was.
def put(arr, src) = (arr[1, src.length] = src)
def widen(h) = h.is_a?(Integer) ? h : h

# the parameter typed, its callers disagreeing on the source
f = [0.5, 1.5]
put(f, [7])
p f
g = [1, 2, 3]
put(g, ["u"].first(1))
p g

# the parameter boxed
c = [1, 2, 3]
put(widen(c), ["u"].first(1))
p c
d = [0.5, 1.5]
put(widen(d), [7])
p d
e = %w[a b c]
put(widen(e), [:s])
p e

# handed on by another method
def relay(arr, src) = put(arr, src)
h = [1, 2, 3]
relay(h, [nil, "v"])
p h

# a boxed local holding the caller's array
v = [1, 2, 3]
w = [v, "s"][0]
w[0, 1] = ["s"]
p v

# a general Array's elements, through a typed parameter
m = %w[a b c]
put(m, [:s, 1])
p m
