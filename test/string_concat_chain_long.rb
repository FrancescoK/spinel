# A chain of `concat` calls (`s.concat("x").concat("x")...`) whose value is
# kept compiles in time linear in its length. Each link's emitter rendered
# the link below it once to learn whether the receiver's slot could be
# named, which only matters when an argument rebinds the receiver, and again
# for the text, so the compile took twice as long per link: more than ten
# seconds at 20 links and no end in sight at 30. This chain is sixty links
# (make scale-test compiles it under a CPU-time limit, in both builds). Each
# `concat` answers the receiver itself, so the names share every change.
s = +"Ab"
u = s.concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x").concat("x")
t = s
h = {k: t, j: u}
s.upcase!
p h, t.size, u.equal?(s)
a = +"q"
b = (a.concat("1").concat("2")).concat("3", "4").concat("5")
p b, b.size
d = +"m"
e = d.concat("y").concat(d = +"z").concat("w")
p d, e
