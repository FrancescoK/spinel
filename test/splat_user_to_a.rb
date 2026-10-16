# `*obj` converts a program object through its #to_a: one the class
# defines, one an alias names, and one Enumerable supplies, whether the
# operand's class is known or the value arrives untyped.
class Node
  def initialize(c) = @children = c
  attr_reader :children
  alias to_a children
end

class Pair
  def initialize(a, b)
    @a = a
    @b = b
  end
  def items = [@a, @b]
  alias to_a items
end

class Digits
  def to_a = [1, 2, 3]
end

class Nothing
  def to_a = nil
end

class Five
  def to_a = 5
end

class Bag
  include Enumerable
  def each
    yield 7
    yield 8
  end
end

class Plain; end

n = Node.new([:a, 1])
x, = *n
p x
y, z = *n
p [y, z]
p [*n]

def first(arg)
  name, = *arg
  name
end

def all(arg) = [*arg]

def assign(arg)
  x = *arg
  x
end

def count(*xs) = xs.size

def spread(arg) = count(*arg)

[Node.new([:b, 2]), Pair.new(:c, 3), Digits.new, Bag.new, nil, [:d], "s", 4, {k: 1}, (1..2)].each do |v|
  p [first(v), all(v), assign(v), spread(v)]
end
p all(Nothing.new).map(&:class)
p all(Plain.new).map(&:class)
begin
  all(Five.new)
rescue TypeError => e
  p e.message
end

# #to_a answering something other than an Array is a TypeError, whether
# the class is known (a def, an alias of a reader) or the value is boxed;
# a boxed nil answer spreads the object itself
class Holder
  def initialize(v) = @v = v
  attr_reader :v
  alias to_a v
end

class Six
  def to_a = 6
end

[5, nil, [1, 2], {a: 1}].each do |v|
  begin
    p [*Holder.new(v)].map(&:class)
  rescue TypeError => e
    p e.message
  end
end
begin
  p [*Six.new]
rescue TypeError => e
  p e.message
end
begin
  a, b = *Six.new
  p [a, b]
rescue TypeError => e
  p e.message
end
begin
  p all(Holder.new(7))
rescue TypeError => e
  p e.message
end

# an answer that is a value or nil: the value is a TypeError, nil spreads
# the object itself, wherever the splat lands
class MaybeInt
  def initialize(c) = @c = c
  def to_a = (@c ? 5 : nil)
end

class MaybeStr
  def initialize(c) = @c = c
  def to_a = (@c ? "s" : nil)
end

[true, false].each do |c|
  [MaybeInt.new(c), MaybeStr.new(c)].each do |o|
    begin
      p [*o].map(&:class)
    rescue TypeError => e
      p e.message
    end
    begin
      p count(*o)
    rescue TypeError => e
      p e.message
    end
    begin
      a, b = *o
      p [a.class, b]
    rescue TypeError => e
      p e.message
    end
  end
end
p [*Nothing.new].map(&:class)

# a receiver that may be nil: nil.to_a spreads nothing
def held(v) = [*v]
p held(Holder.new([1]))
p held(nil)
