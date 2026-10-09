# A Struct member named after one of Struct's iterators (each, each_pair,
# each_with_index) is read by its accessor, which the struct defines over
# the iterator it inherits. They answered the iterator's Enumerator (#8203).
Row = Struct.new(:each, :each_pair, :each_with_index)
r = Row.new(5, 6, 7)
p r.each
p r.each_pair
p r.each_with_index
p r.to_a
r.each = 50
p r.each

Pt = Struct.new(:each, :y)
q = Pt.new(1, 2)
p q.each
q.each_pair { |k, v| p [k, v] }
p q.to_a

Plain = Struct.new(:a, :b)
s = Plain.new(1, 2)
s.each { |v| p v }
p s.each_pair.to_a
