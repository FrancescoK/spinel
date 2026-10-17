# A String stored into an Array through parentheses -- `r << (+"a")`,
# `r[i] = (c ? +"a" : +"b")` -- is the element a later in-place change
# reaches. The handle demand landed on the parenthesis alone while the box
# was emitted for the statement inside it, so the element was a plain box
# over a copy and `r[0] << "^"` was lost.
c = ARGV.size == 0
s = +"s"
t = "t"
r = []
r << (+"a")
r << (c ? +"b" : +"x")
r << (t.dup)
r << ((+"n"))
r << (s)
r.each { |e| e << "^" }
r[1] << "?"
p r, s

w = Array.new(5)
w[0] = (+"a")
w[1] = (c ? +"b" : +"x")
w[2] = (t.dup)
w[3] = ((c ? +"n" : +"x"))
w[4] = (s)
w.each { |e| e << "!" }
w[3] << "?"
p w, s, t
