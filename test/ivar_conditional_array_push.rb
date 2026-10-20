# An ivar whose writes join an Array with a nil or an Array of another kind
# (`@a = c ? [1, 2] : nil`, `@a = c && [1, 2]`), then given an element of
# another kind. The search for the arrays a pushed value must fit followed a
# boxed local through its writes, not a boxed ivar, so the literal stayed an
# Array of Integers and the push raised "cannot store String into an
# Array[Integer]" where CRuby appends it.
class K
  def initialize(c)
    @a = c ? [1, 2] : nil
    @b = c && [3, 4]
    @c = c ? [5] : ["x"]
    @d = nil
    @d = [6] if c
  end

  def add
    @a << "s"
    @b << :b
    @c << 1.5
    @d << "d"
    [@a, @b, @c, @d]
  end
end

p K.new(true).add

class L
  def initialize(c) = @a = c || [1, 2]
  def add = (@a << "s" if @a.is_a?(Array); @a)
end
p L.new(false).add, L.new(true).add
