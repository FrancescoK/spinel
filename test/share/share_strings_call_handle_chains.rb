# Appends and inserts chained on a method's answer that is the String it was
# handed land on that String, through every name of it, with the method
# called once; a freeze over the chain freezes it. Statements and values,
# chains of one to three links, `<<`, `concat` of one or two Strings and
# `insert` mixed.
$calls = 0
def id(v)
  $calls += 1
  v
end

a = +"a"
a2 = a
id(a) << "1" << "2"
p a, a2, $calls

b = +"b"
b2 = b
id(b) << "1" << "2" << "3"
p b, b2, $calls

c = +"c"
c2 = c
id(c).concat("1").insert(0, ">") << "2"
p c, c2, $calls

d = +"d"
d2 = d
id(d).concat("p", "q") << "r"
p d, d2, $calls

e = +"e"
e2 = e
r = id(e) << "1" << "2"
p r, e2, r.equal?(e), $calls

f = +"f"
f2 = f
r = id(f).insert(0, "<").concat("x", "y") << "z"
p r, f2, r.equal?(f), $calls

g = +"g"
g2 = g
r = (id(g) << "1" << "2").freeze
p r.equal?(g2), g2.frozen?, g2, $calls

h = +"h"
h2 = h
(id(h).concat("1") << "2").freeze
p h2.frozen?, h2, $calls

t = +"t"
t2 = t
id(t).upcase!.freeze
p t2.frozen?, t2, $calls
u = +"U"
u2 = u
id(u).upcase!.freeze
p u2.frozen?, u2, $calls
