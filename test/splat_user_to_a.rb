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
