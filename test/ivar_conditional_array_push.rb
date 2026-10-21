# An ivar whose writes join an Array with a nil or an Array of another kind
# (`@a = c ? [1, 2] : nil`, `@a = c && [1, 2]`), then given an element of
# another kind. The search for the arrays a pushed value must fit followed a
# boxed local through its writes, not a boxed ivar, so the literal stayed an
# Array of Integers and the push raised "cannot store String into an
# Array[Integer]" where CRuby appends it. The same when the value pushed is a
# box (a method's parameter its callers hand different kinds, an element of
# an Array of both kinds): the widening is for it too, in an ivar and a
# local.
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

class M
  def initialize(f) = @a = f ? [1, 2] : nil
  def add(v) = (@a << v; self)
  def all = @a
end
m = M.new(true)
m.add("s").add(:y).add(2.5)
p m.all

class N
  def initialize(f) = @a = (f && [1, 2]) || [3]
  def add(v) = @a << v
  def sum_ints = @a.select { |e| e.is_a?(Integer) }.sum
end
n = N.new(true)
n.add("s")
p n.add(7), n.sum_ints

class O
  def initialize(f) = (@a = f ? [1.5] : nil; @b = @a)
  def add(v) = @a << v
  def b = @b
end
o = O.new(true)
o.add("s")
p o.b, o.b.equal?(o.add(1))
GC.start
p o.b.size

class P
  def initialize(f) = @a = f ? [1, 2] : nil
  def run
    ["s", 3].each { |v| @a << v }
    @a
  end
end
p P.new(true).run

x = ARGV.empty? && [1, 2]
["s", 3].each { |v| x << v }
p x
