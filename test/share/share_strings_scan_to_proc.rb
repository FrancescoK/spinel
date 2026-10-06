# Flag-only: without the flag (as on master) the answers are copies when the
# String is not otherwise shared.
# String#scan with a block answers the receiver itself, and a Hash's
# to_proc answers the Hash's own values through its calls.
s = +"hello"
t = s.scan("l") { |m| m }
t << "!"
p [s, t.equal?(s)]

r = +"abc"
u = r.scan(/b/) { |m| m.size }
r << "?"
p u

e0 = +"e0"; e1 = +"e1"; k0 = +"a"
h = {k0 => e0, +"b" => e1}
v = h.to_proc.call(k0)
p [v.equal?(e0), v == e0]
v << "!"
p h

pr = h.to_proc
w = pr.call("b")
w << "?"
p [e1, w.equal?(e1)]
p pr.call("zz")
