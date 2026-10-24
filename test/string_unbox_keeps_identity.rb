# A boxed String unboxed into a String slot (a splat pushed into a String
# Array, a poly element stored into a typed one) was a copy of the String's
# bytes: `a.push(*xs)` filled a with second Strings, and a change through
# a did not reach xs.
xs = [+"p", +"q"]
a = []
a.push(*xs)
a[0] << "!"
p xs
b = []
b.concat(xs)
b[1] << "?"
p xs
c = xs + []
c[0] << "#"
p xs
ys = [+"m", 1][0]
zs = [+"n"]
zs[0] = ys
zs[0] << "!"
p ys
