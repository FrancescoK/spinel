# `obj.attr ||= v` and `&&=` on an attr_accessor or a Struct member test the
# slot's own nil for every value kind, build the value at the slot's type,
# and a pointer slot never written on this object takes the value (#5428).
class P
  attr_accessor :tags, :n, :name, :sym, :f, :h, :flag
end
b = P.new
b.tags ||= []
b.tags << "new"
p b.tags
b.n ||= 3; b.n ||= 9; p b.n
b.name ||= "x"; p b.name
b.sym ||= :s; p b.sym
b.f ||= 1.5; p b.f
b.h ||= {}; b.h[:k] = 1; p b.h
b.flag ||= true; p b.flag
x = (b.tags ||= ["no"]); p x
c = P.new
c.tags &&= ["and"]; p c.tags
c.tags = ["t"]; c.tags &&= ["t2"]; p c.tags
S = Struct.new(:tags, :count)
s = S.new
s.tags ||= []
s.tags << 1
s.count ||= 0
s.count += 1
p s.tags, s.count
Q = Struct.new(:v)
q = Q.new(nil)
v = (q.v ||= "val")
p v, q.v

class P2
  attr_accessor :tags
end
P2.new.tags = %w[a]
b2 = P2.new
b2.tags ||= []
b2.tags << "new"
p b2.tags
