# Attribute writes through a boxed receiver (two Structs share the member):
# a Float into a member set to Integers elsewhere, and a number that may be
# nil written as a statement, keep what was written.
A = Struct.new(:val)
B = Struct.new(:val)

r = [A.new(0), B.new(0)]
r.each { |s| s.val = 2.5 }
p r[0].val, r[1].val
r.each { |s| s.val = 7 }
p r[0].val, r[1].val

q = [A.new(1.5), B.new(2.5)]
q.each_with_index { |s, i| s.val = (i == 0 ? nil : 1.0) }
p q[0].val, q[1].val

w = [A.new(0), B.new(0)]
w.each_with_index { |s, i| t = (s.val = (i == 0 ? 2.5 : nil)); p [t, s.val] }
w.each_with_index { |s, i| s.val = (i == 0 ? 2.5 : nil); p s.val }
