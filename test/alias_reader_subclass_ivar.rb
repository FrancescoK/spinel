# A subclass's instance read through an alias of its superclass's own
# attr_reader (`attr_reader :location; alias loc location`) answers what the
# subclass's instance holds. The alias was turned into a forwarder over an
# inherited method, and the reader's ivar was looked up by the alias's name,
# so the value's class was unknown and its method had no arm.
class A
  def initialize(properties) = assign_properties(properties)
  def assign_properties(_properties) = nil
end

class B < A
  attr_reader :location
  alias loc location
  attr_accessor :size
  alias_method :len, :size

  def assign_properties(properties)
    @location = properties[:location]
    @size = properties[:size]
  end
end

class C < B
  def initialize(properties)
    @y = {}
    super
  end

  def source_range = loc.val
  def length = len + 1
end

class V
  def val = 42
end

c = C.new({ location: V.new, size: 3 })
p c.source_range, c.length, c.loc.class, B.new({ location: V.new, size: 1 }).loc.val

# a subclass's own reader of the alias's name reads its own ivar
class W
  def wal = "w"
end
class D < B
  attr_reader :loc
  def initialize(properties)
    @loc = W.new
    super
  end
end
d = D.new({ location: V.new, size: 2 })
p d.loc.wal, d.location.val

# a subclass's instance method or reader of the name does not hide a class
# method alias an ancestor declares
class SP
  class << self
    def bar = "SP.bar"
    alias foo bar
  end
end
class SC < SP
  def foo = "SC#foo"
  attr_reader :bar
end
p SC.foo, SC.new.foo
