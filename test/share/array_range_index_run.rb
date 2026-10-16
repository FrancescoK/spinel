# `a[r]` and `a[i, n]` on an Array answer an Array of the receiver's own
# elements: the run holds the same Strings, and a String the run hands
# out is one of them, not the Array itself.
t = +"abc"
s = [t, 1][0..0].first
acc = []
s.scan(/./) { |m| m << "!"; acc << m }
p acc, t
u = +"uv"
run = [u, 2, +"w"][0, 2]
run[0] << "?"
p u, run
w = [u, 3][0..].first
w << "#"
p u, w.equal?(u)
