# grep answers an Array blockless, so `a.grep(p).each { }` walks that Array
# (it is no Enumerator chain), and an inlined grep in a method whose own
# value is of another array kind keeps its own result kind.
class Foo
  def initialize(n) = @n = n
  attr_reader :n
end
[1, "a", 2].grep(Integer).each { |t| p t }
def ns(r) = r.grep(Foo).map(&:n)
p ns([Foo.new(1), "s", Foo.new(3)])
results = [[Foo.new(4), 5], 0][0]
Array === results and results.grep(Foo).each { |t| p t.n }
