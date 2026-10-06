# Flag-only: without the flag (as on master) the Strings below are copies.
# An iterator that answers its receiver hands back the receiver itself, so
# a change through the answer shows in the receiver and the other way
# round. The share rows read each_char, each_line, each_byte,
# each_grapheme_cluster, scan, Array#each_index and Hash#each_key as
# answering a fresh value: the answer was a copy, or (each_key) the program
# was refused. tap's row said the receiver, but its answer was a copy too. sort!, uniq!, sort_by! and cycle answered right through
# rows that said otherwise, and still do.
s = +"ab"
r = s.each_char { }
r << "!"
p s
p r.equal?(s)
l = +"a\nb"
r = l.each_line { |x| }
l << "?"
p r
b = +"ab"
r = b.each_byte { |x| }
r << "1"
p b
g = +"gh"
r = g.each_grapheme_cluster { }
r << "2"
p g
m = +"abab"
seen = []
r = m.scan(/a/) { |x| seen << x }
r << "3"
p m
p seen
pr = proc { |c| c }
f = +"f"
r = f.each_char(&pr)
r << "5"
p f
w = +"w"
held = [w.each_char { }]
held[0] << "4"
p w
t = +"ab"
t << "c"
r = t.tap { }
r << "!"
p t
t = +"ab"
r = t.tap { |x| x << "1" }
r << "!"
p t
p r.equal?(t)
a = [+"x"]
r = a.each_index { }
r[0] << "!"
p a
p r.equal?(a)
h = { "k" => +"v" }
r = h.each_key { }
r["k"] << "!"
p h
p r.equal?(h)
o = [+"b", +"a"]
r = o.sort!
r[0] << "!"
p o
u = [+"c", +"c"]
r = u.uniq!
r[0] << "?"
p u
p u.uniq!
v = [+"e", +"d"]
r = v.sort_by! { |e| e }
r[1] << "+"
p v
y = [+"z"]
p y.cycle(1) { |e| e << "~" }
p y
