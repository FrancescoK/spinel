# spinel: share
# spinel: gc-stress
# A String Range's step(n) and % build the stepped Enumerator from three
# fresh objects: the Enumerator, the boxed Range it reports as its source and
# its "step(n)" label. Each is held while the next is allocated, so a
# collection between them leaves the Enumerator reading back what it holds.
r = ("aa".."ad")
p r.step(2).to_a
p (r % 2).to_a
e = r.step(3)
GC.start
p e, e.next
a = String.new("a")
p (a.."e").step(2).to_a
p ((+"x" + "a")..("x" + "d")).step(2).to_a
p (("aa".."ad") % 2).to_a.last
m = ("aa"..."ad").step(1)
p m.to_a, m.inspect
# gsub with no block builds the same kind of Enumerator: the matches, the
# receiver as its source and a "gsub(pattern)" label, all allocated in turn.
p ("abc" * 3).gsub("b").to_a.size
p ("abc" * 3).gsub(/c/).to_a.size
g = ("abc" * 3).gsub(/b/)
GC.start
p g, g.next
