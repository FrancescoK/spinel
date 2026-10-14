# spinel: share
# spinel: gc-minor
# A literal that splats an Array is not an Array of shared Strings that
# holds each as its handle: the splat spreads its elements, where the handle
# form would push the Array as one.
s = +"ab"
x = ["q", "r"]
a = [s, *x]
b = [s, *["m", "n"]]
c = [*["k"], s]
s << "!"
p a, b, c, a.size, b.size, c.size
b << +"o"
b[0] << "?"
p b, s

# a literal without one keeps the handles
d = [s, "d"]
s << "."
p d, d[0].equal?(s)
