# A Struct's blockless each_with_index answers an Enumerator over the
# [member, index] pairs, as Enumerable's does; the block form still yields
# and answers the struct.
Pair = Struct.new(:a, :b)
pr = Pair.new(1, 2)
p pr.each_with_index.to_a
p pr.each_with_index.map { |x, i| x * 10 + i }
e = pr.each_with_index
p e.next
p pr.each.to_a
p pr.each_pair.to_a
r = pr.each_with_index { |x, i| p [x, i] }
p r
Named = Struct.new(:name, :tag)
p Named.new("n", :t).each_with_index.to_a
