# A block whose last value is a constant holding a String the program
# changes in place (`A::X`) gives `p yield` that String: the yield's type
# at the site was the constant's storage form, which `p` did not take.
module A
  X = +"a"
  def self.f = X
end
module B
  X = 2
  def self.g = X
end
def show
  p yield
rescue NameError => e
  p e.message
end
show { A::X }
show { B::X }
show { A.f }
show { B.g }
A::X << "z"
show { A::X }
show { A::X.frozen? }
module C
  def self.h = Y
end
show { C.h }
module C
  Y = 1
end
show { C.h }
# the yield's String is the constant's own object: identity, containers,
# appends and the value a method answers all see it
def same = p(yield.equal?(A::X))
same { A::X }
def same_id = p(yield.object_id == A::X.object_id)
same_id { A::X }
def in_array = p([yield].first.equal?(A::X))
in_array { A::X }
def in_hash = p({k: yield}[:k].equal?(A::X))
in_hash { A::X }
def put = puts(yield)
put { A::X }
def app = yield << "!"
app { A::X }
p A::X
def kept
  r = yield
  r.equal?(A::X)
end
p kept { A::X }
def give = yield
r = give { A::X }
r << "?"
p A::X, r.equal?(A::X)
module F
  X = "f"
end
show { F::X }
q = give { F::X }
p q, q.frozen?
a = [give { A::X }]
a[0] << "#"
p A::X
# a site whose block answers nil ahead of one answering the constant, a
# method answering it, a block that forwards the yield, a next that hands
# it on, and a local's String the same way
def same2 = p(yield.equal?(A::X), yield.object_id == A::X.object_id)
same2 { nil }
same2 { A::X }
def mk_c = A::X
same { mk_c }
def show_c = p(yield)
show_c { mk_c }
def inner_y = p(yield.equal?(A::X))
def outer_y = inner_y { yield }
outer_y { A::X }
outer_y { +"q" }
def nx(c) = p(yield(c).equal?(A::X))
nx(true) { |c| next A::X if c; +"x" }
nx(false) { |c| next A::X if c; +"x" }
def same_o(o) = p(yield.equal?(o))
s = +"lo"
s << "c"
same_o(s) { nil }
same_o(s) { s }
mr = mk_c
mr << "%"
p A::X, mr.equal?(A::X)
