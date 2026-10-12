# A String method that answers its receiver, called on a value route over
# a variable (`(+s) << x`, `(+s).concat(x)`), answers that variable's
# String when s is not frozen, a new one when it is. Stored where a box
# holds it, the box held a copy of the bytes.
s = +"ab"
s << "c"
x = 1
x = (+s) << "!"
p x.equal?(s)
s << "?"
p x
y = nil
y = (+s).concat("-")
p y.equal?(s), s
f = "fr"
z = 2
z = (+f) << "+"
p z, f, z.equal?(f), z.frozen?
a = [1]
a << ((+s) << "#")
p a[1].equal?(s), s
# each method that answers its receiver, on the route, into a box and a
# String variable, over a String that is not frozen and one that is
t0 = +"ab"
t0 << "c"
b0 = 1
b0 = (+t0).insert(0, "<")
v0 = (+t0).insert(0, "<")
p b0, v0, t0, b0.equal?(t0), v0.equal?(t0)
g0 = 2
g0 = (+"fz").insert(0, "<")
p g0, g0.frozen?
t1 = +"ab"
t1 << "c"
b1 = 1
b1 = (+t1).clear
v1 = (+t1).clear
p b1, v1, t1, b1.equal?(t1), v1.equal?(t1)
g1 = 2
g1 = (+"fz").clear
p g1, g1.frozen?
t2 = +"ab"
t2 << "c"
b2 = 1
b2 = (+t2).force_encoding("UTF-8")
v2 = (+t2).force_encoding("UTF-8")
p b2, v2, t2, b2.equal?(t2), v2.equal?(t2)
g2 = 2
g2 = (+"fz").force_encoding("UTF-8")
p g2, g2.frozen?
t3 = +"ab"
t3 << "c"
b3 = 1
b3 = (+t3).encode!("UTF-8")
v3 = (+t3).encode!("UTF-8")
p b3, v3, t3, b3.equal?(t3), v3.equal?(t3)
g3 = 2
g3 = (+"fz").encode!("UTF-8")
p g3, g3.frozen?
t4 = +"ab"
t4 << "c"
b4 = 1
b4 = (+t4).scrub!
v4 = (+t4).scrub!
p b4, v4, t4, b4.equal?(t4), v4.equal?(t4)
g4 = 2
g4 = (+"fz").scrub!
p g4, g4.frozen?
t5 = +"ab"
t5 << "c"
b5 = 1
b5 = (+t5).append_as_bytes("!")
v5 = (+t5).append_as_bytes("!")
p b5, v5, t5, b5.equal?(t5), v5.equal?(t5)
g5 = 2
g5 = (+"fz").append_as_bytes("!")
p g5, g5.frozen?
t6 = +"ab"
t6 << "c"
b6 = 1
b6 = (+t6).each_char { }
v6 = (+t6).each_char { }
p b6, v6, t6, b6.equal?(t6), v6.equal?(t6)
g6 = 2
g6 = (+"fz").each_char { }
p g6, g6.frozen?
t7 = +"ab"
t7 << "c"
b7 = 1
b7 = (+t7).concat("a", "b")
v7 = (+t7).concat("a", "b")
p b7, v7, t7, b7.equal?(t7), v7.equal?(t7)
g7 = 2
g7 = (+"fz").concat("a", "b")
p g7, g7.frozen?
t8 = +"ab"
t8 << "c"
b8 = 1
b8 = (+t8).upcase!
v8 = (+t8).upcase!
p b8, v8, t8, b8.equal?(t8), v8.equal?(t8)
g8 = 2
g8 = (+"fz").upcase!
p g8, g8.frozen?
# a chain of receiver-answering calls over the route
c1 = +"ab"
c1 << "c"
d1 = 1
d1 = (+c1).insert(0, "<").insert(0, "[")
p d1, c1, d1.equal?(c1)
d2 = (+c1).insert(0, "(").upcase!
p d2, c1, d2.equal?(c1)
