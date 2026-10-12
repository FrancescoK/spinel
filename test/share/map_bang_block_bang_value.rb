# A block whose value is a String bang on a boxed parameter (`&:upcase!`) answers
# that parameter's own String, or nil where the bang changed nothing, and
# map! stores it as it is, as a `next` with such a value hands it on: the
# element is the String the variable holds, changed in place.
s = +"abc"
t = s
r = [s].map!(&:upcase!)
p s, t, r, r[0].equal?(s)
u = +"xyz"
v = [u, 1]
q = [u].map! { |x| x.strip! }
p q, u
w = +"pq"
a = [w].map { |x| next x.upcase! }
a[0] << "!"
p a, w
b = [+"Mn", +"OO"]
b.map!(&:swapcase!)
p b
