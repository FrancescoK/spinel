# spinel: gc-stress
# A bare `super` in a forwarding `self.new(*args, **options)` binds
# initialize's parameters in order, each default reading the earlier ones.
# A default that builds a new value (a downcase, an interpolation) was bound
# to an unrooted local, and the next default's allocation freed it before
# the constructor took it: under SPINEL_GC_STRESS=2 the object kept a freed
# String.
class Dep
  def self.new(*args, **options, &block)
    object = args.first
    return object unless object
    super
  end

  def initialize(old_const, new_const, tag = old_const.downcase, message: "#{old_const} is gone! Use #{new_const}.")
    @tag = tag
    @msg = message
  end
  attr_reader :tag, :msg
end

class Pair
  def self.new(*args, **options)
    super
  end

  def initialize(a, b = "#{a}-b", c = "#{b}!".upcase)
    @a = a
    @b = b
    @c = c
  end
  attr_reader :a, :b, :c
end

d = Dep.new("Old", "New")
p d.tag, d.msg
x = Pair.new("p")
p x.b, x.c
y = Pair.new("q", "r")
p y.b, y.c
