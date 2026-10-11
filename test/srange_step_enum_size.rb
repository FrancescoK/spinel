# spinel: share
# spinel: gc-stress
# A String Range counts no members without walking them, so the Enumerators
# its step and % answer have no size (nil), as the Range's own size is. The
# stepped members are materialized, and their count was answered.
r = ("aa".."ad")
p r.step(2).size, (r % 2).size, r.step(1).size
e = r.step(2)
p e.size, e.to_a.size
e.next
p e.size
p (("a"..."e") % 3).size
p r.size
# the members and the Integer and Float Ranges' sizes are unchanged
p r.step(2).to_a, (r % 2).to_a
p (1..10).step(3).size, ((1..10) % 3).size, (1...10).step(3).size
p (1.0..2.0).step(0.5).size, (1..).step(2).size
p (1..10).each_slice(3).size
# what is built on such an Enumerator has no size either: the size of a
# derived Enumerator is its source's, and a String Range's is unknown
p r.step(2).with_index.size, r.step(2).with_index(1).size
p r.step(2).each_with_index.size, (r % 2).with_index(1).size
p r.step(2).each_slice(2).size, r.step(2).each_cons(2).size
p r.step(2).with_index.with_index.size
e = r.step(2).each_slice(2)
p e.size, e.to_a
p r.step(2).with_index.to_a, r.step(2).each_with_index.to_a
p r.step(2).each_cons(2).to_a
# an Array's Enumerators keep their sizes, whatever it was made from
p r.step(2).to_a.each.size, r.step(2).to_a.each_slice(2).size
p r.to_a.each_cons(2).size, r.to_a.each_with_index.size
p (1..10).step(3).each_slice(2).size
# and neither have the Enumerators the Range's own blockless calls answer
p r.each.size, r.each_slice(2).size, r.each_cons(2).size
p r.each_with_index.size, r.each_entry.size, r.cycle.size, r.cycle(2).size
p r.each_slice(2).with_index.size, r.each_cons(2).each_with_index.size
e = r.each_slice(2)
p e.size, e.to_a, e.next
p r.each_cons(3).to_a, r.each_with_index.to_a
