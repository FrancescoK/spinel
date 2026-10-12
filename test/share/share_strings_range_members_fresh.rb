# --share-strings: a String Range's members are new Strings its walk makes
# (CRuby's String#upto hands on a copy of each), so the Arrays first(n),
# last(n), take, to_a, entries, min(n) and max(n) answer hold no endpoint.
# The share walk took them for Arrays of the endpoints, and a change
# through one of their elements (`y = q.first(1)[0]; y << "!"`) was
# refused once an endpoint was changed in place (#6765). Neither change
# shows through the other. #first with no count still answers the begin.
# spinel: gc-stress

s = String.new("a")
e = String.new("c")
q = s..e
y = q.first(1)[0]
y << "!"
p y, s, q

x = q.first(2)
l = q.last(2)
z = q.to_a
w = q.take(1)
v = q.min(1)
u = q.max(1)
t = q.entries
x[0] << "1"
l[1] << "2"
z[0] << "3"
w[0] << "4"
v[0] << "5"
u[0] << "6"
t[2] << "7"
p s, e, q, x, l, z, w, v, u, t

# a change to an endpoint does not show through them
s << "8"
e << "9"
p x, l, z, q.first(1), q.last(1)

# handed to a block, or kept in a variable
def yy(r) = yield(r.first(2))
yy(q) { |a| a[0] << "!" }
k = q.last(1)
k[0] << "?"
p q, k

# the endpoints themselves
mm = q.minmax
p mm
f = q.first
f << "F"
p q
