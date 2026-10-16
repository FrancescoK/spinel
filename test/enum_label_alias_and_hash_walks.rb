# A blockless collect and find_all answer Enumerators labeled collect and
# find_all, and a Hash's each_key, each_value, each_pair, each_slice and
# each_cons are labeled with the Hash and the call, as in CRuby. spinel
# labeled them map and select, and the Hash's with its keys, its values or
# its pairs and `each`. A walk of a stored one answers the Hash.
def box(v) = [v, "z"][0]
a = [3, 1, 2]
p a.collect, a.find_all, box(a).collect, box(a).find_all
p a.collect.with_index { |x, i| x + i }, a.find_all.with_index { |x, i| i.odd? }

h = { a: 1, b: 2 }
p h.each_key, h.each_value, h.each_pair, h.each
p h.each_slice(1), h.each_cons(2), box(h).each_key, box(h).each_pair, box(h).each_slice(1)

k = h.each_key
p k.next, k.size, k.map { |x| x }, k.with_index { } == h
v = h.each_value
p v.with_index(1).to_a, v.each { } == h, v.sum
pr = h.each_pair
p pr.with_index { } == h, pr.to_a
s = h.each_slice(1)
p s.to_a, s.size, s.each { } == h
c = box(h).each_cons(2)
p c.to_a, c.each { } == h
