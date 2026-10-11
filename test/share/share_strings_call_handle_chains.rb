# Appends and inserts chained on a method's answer that is the String it was
# handed land on that String, through every name of it, with the method
# called once; a freeze over the chain freezes it. Statements and values,
# chains of one to three links, `<<`, `concat` of one or two Strings and
# `insert` mixed, with `&.` and bang links, as method tails, and on a receiver
# whose text is long.
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

# a chain over such a call as a method's last expression, endless and not
def tail(s) = id(s) << "t1" << "t2"
def tail2(s)
  id(s) << "u1" << "u2"
end
v = +"v"
p tail(v).equal?(v), v, $calls
w = +"w"
p tail2(w).equal?(w), w, $calls

# a bang, an append or a concat before `&.`, and after it: each call once
i = +"i"
i2 = i
id(i).upcase!&.upcase!
p i2, $calls
j = +"j"
j2 = j
id(j).upcase! << "Z"
p j2, $calls
k = +"k"
k2 = k
p((id(k) << "1" << "2")&.concat("Z"))
p k2, $calls
l = +"l"
l2 = l
id(l).upcase!&.concat("2") << "3"
p l2, $calls
m = +"m"
m2 = m
(id(m) << "1")&.concat("2") << "3"
p m2, $calls
n = +"n"
n2 = n
id(n).concat("1").concat("2")&.upcase!
p n2, $calls
o = +"o"
o2 = o
id(o).concat("1")&.concat("2") << "3"
p o2, $calls

# prepend of two Strings, then insert, as a value and as a method's tail;
# insert as an argument and in an interpolation
q = +"q"
q2 = q
x = id(q).prepend("1", "2").insert(0, "Z")
p x, q2, $calls
def pre(s) = id(s).prepend("3", "4").insert(0, "Y")
y = +"y"
p pre(y), y, $calls
z = +"z"
p(id(z).concat("1").insert(0, "e"))
p z, "#{id(z).upcase!.insert(0, "f")}", z, $calls

# a setbyte or force_encoding on a receiver whose text is long
def with_a_long_method_name_for_the_receiver_text_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(x)
  $calls += 1
  x
end
s = +" abc "
s2 = s
with_a_long_method_name_for_the_receiver_text_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(with_a_long_method_name_for_the_receiver_text_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(with_a_long_method_name_for_the_receiver_text_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(with_a_long_method_name_for_the_receiver_text_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(s)))).setbyte(0, 65)
p s2, $calls
with_a_long_method_name_for_the_receiver_text_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(with_a_long_method_name_for_the_receiver_text_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(with_a_long_method_name_for_the_receiver_text_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(with_a_long_method_name_for_the_receiver_text_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(s)))).force_encoding("BINARY")
p s2.encoding, $calls
