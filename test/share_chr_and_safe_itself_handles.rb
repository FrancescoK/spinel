# Two Strings a shared variable took as copies, though nothing refused
# them (#9258's re-measurement): a chr on a boxed receiver answers a new
# String each call, boxed as its bytes (a one-character table's), so an
# append through the variable left the Array's element as it was; and
# `x&.itself` is x, whose handle the variable took a copy of.

x = [+"ab", 1].first
r = x.ord.chr
a = [r, 1]
r << "!"
p r, a

y = [1, +"q"].first
s = (y + 64).chr
b = [s]
s << "?"
p s, b

c = [+"ab", +"cd"]
w = c[0].upcase!&.itself
w << "#"
p w, c

d = [+"kl", +"mn"]
v = d[1].upcase!&.itself
v << "%" if v
u = d[0]&.itself
u << "&"
p v, d
