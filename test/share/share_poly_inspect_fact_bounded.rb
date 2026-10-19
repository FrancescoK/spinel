# A boxed receiver's call of a name a builtin answers too (inspect), where
# a class's own inspect publishes an ivar and another's answers a literal.
# Over an Array of Symbols the receiver's class fact rules the classes out:
# the walk follows no class's method, and each inspect is a new String. Over
# the objects each arm boxes its own answer, so the published ivar keeps its
# identity through the Array (#9258).
class Foo
  def initialize(n)
    @n = n
  end
  attr_reader :n
  def inspect
    @n
  end
end
class Bar
  def initialize(m)
    @m = m
  end
  def inspect = "Bar"
end
SEV = [:error, :warning, :info].freeze
def sev_list
  SEV.map(&:inspect).join(", ")
end
def pair_list
  [:a, :b].map { |x| x.inspect }.join("/")
end
foo = Foo.new(String.new("foo"))
bar = Bar.new(String.new("bar"))
arr = [1, :a, foo]
s = arr.map(&:inspect)
puts sev_list
puts pair_list
foo.n << "?"
puts s.join(", ")
s[2] << "!"
puts foo.n
puts [bar, foo].map(&:inspect).join(" ")
