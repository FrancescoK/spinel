# index / rindex / find_index with a value argument and a block: the value
# form answers, and the block is not used (CRuby warns "given block not used")

a = [3, 2, 2]
p a.index(2) { true }
p a.rindex(2) { true }
p a.find_index(2) { true }
p a.index(9) { true }
f = [1.5, 2.5]
p f.index(2.5) { true }
p f.rindex(1.5) { |x| false }
s = ["a", "b"]
p s.index("b") { true }
p s.find_index("a") { false }

m = [1, "a", :b]
p m.index(:b) { true }
p m.rindex(1) { true }
p m.find_index("a") { true }

p (1..5).find_index(3) { true }
p ("a".."e").find_index("c") { false }
p({a: 1, b: 2}.find_index([:b, 2]) { false })
p [5, 6].each.find_index(6) { false }
p (1..3).each_slice(1).find_index([3]) { true }

b = [[1, 2], "s"][0]
p b.index(2) { true }
p b.rindex(1) { true }
p b.find_index(2) { false }

def g(x) = x.index(2) { true }
p g([2, 2])
p g([1, "x", 2])

# the block form still runs the block
p a.index { |x| x == 2 }
p a.rindex { |x| x == 3 }
p m.rindex { |x| x == 1 }
p b.index { |x| x == 2 }

# a program's own index still gets the block
class U
  def index(v) = yield(v)
end
p U.new.index(3) { |x| x * 2 }
[U.new, [1, 3]].each { |o| p o.index(3) { |x| x * 10 } }
