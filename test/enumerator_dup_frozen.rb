# Enumerator#dup answers an unfrozen copy and #clone keeps the frozen state;
# the copy enumerates as the original does
e = [1, 2].each.freeze
d = e.dup
c = e.clone
p [d.frozen?, c.frozen?, e.frozen?]
p d.next, d.to_a
f = [1, 2].each
p [f.dup.frozen?, f.clone.frozen?]
