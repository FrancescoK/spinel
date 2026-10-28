# A method that hands its own block to Array.new (`Array.new(n, &b)`) and is
# called with no block builds [nil] * n, as Array.new(n) does; it raised
# LocalJumpError. The same holds for an initialize run from `new` and for
# `super(n, &b)` in an Array subclass's initialize.
def build(n, &b) = Array.new(n, &b)
p build(2)
p build(3) { |i| i * 3 }
pr = proc { |i| i + 1 }
p build(2, &pr)
p build(2, &nil)

def anon(n, &) = Array.new(n, &)
p anon(2)
p anon(2) { |i| "s#{i}" }

def with_value(n, v, &b) = Array.new(n, v, &b)
p with_value(2, 5)

def sized(n, &b)
  a = Array.new(n, &b)
  a.size
end
p sized(1)
p sized(4) { 0 }

class Maker
  def make(n, &b) = Array.new(n, &b)
  def self.make(n, &b) = Array.new(n, &b)
end
m = Maker.new
p m.make(2)
p m.make(2) { |i| i * i }
p Maker.make(1)
p Maker.make(2) { :z }
p m.send(:make, 2)
p [1, 2].map { |n| build(n) }
p [1, 2].map { |n| build(n) { |i| i - 1 } }

def nested(n, &b) = [n].map { Array.new(n, &b) }
p nested(2)
p nested(2) { 1 }

class Holder
  attr_reader :a
  def initialize(n, &b) = (@a = Array.new(n, &b))
end
p Holder.new(2).a
p Holder.new(2) { |i| i + 1 }.a

class Row < Array
  def initialize(n, &b) = super(n, &b)
end
p Row.new(2)
p Row.new(2) { |i| i + 5 }

class AnonRow < Array
  def initialize(n, &) = super(n, &)
end
p AnonRow.new(1)
p AnonRow.new(2) { |i| i * 2 }

class Table < Hash
  def initialize(&b) = super(&b)
end
p Table.new[:x]
p Table.new { |_, k| k.to_s }[:y]

# a super with the method's own block outside initialize keeps it
class Pairs < Hash
  def map(&b) = super(&b)
end
p Pairs[a: 1, b: 2].map { |k, v| [v, k] }

# an `if block_given?` tail's blockless arm keeps its own kind when
# --int-overflow=promote widens the parameters (it answered nil)
def fill_with(n, v)
  if block_given?
    Array.new(n, v) { |i| yield i }
  else
    Array.new(n, v)
  end
end
p fill_with(2, 5)
p fill_with(2, 5) { |i| i * 7 }

# a block forwarded through super in an Array subclass's own self.new
class Grid < Array
  def self.new(n, &b) = super(n, &b)
end
p Grid.new(2) { |i| i * 3 }
p Grid.new(2)

# an else arm that calls a block_given? method defined after it
def outer(n, v)
  if block_given?
    inner(n, v) { |i| yield i }
  else
    inner(n, v)
  end
end
def inner(n, v)
  if block_given?
    Array.new(n, v) { |i| yield i }
  else
    Array.new(n, v)
  end
end
p outer(2, 5)
p outer(2, 5) { |i| i * 3 }

# initialize called again, with no block
class Again
  def initialize(n, &b)
    @a = Array.new(n, &b)
  end
  def reset(n) = initialize(n)
  attr_reader :a
end
g = Again.new(2) { |i| i + 1 }
p g.a
g.reset(3)
p g.a

# a chain of ten such methods, each defined before the one it calls
def chain0(n) = block_given? ? chain1(n) { |i| yield i } : chain1(n)
def chain1(n) = block_given? ? chain2(n) { |i| yield i } : chain2(n)
def chain2(n) = block_given? ? chain3(n) { |i| yield i } : chain3(n)
def chain3(n) = block_given? ? chain4(n) { |i| yield i } : chain4(n)
def chain4(n) = block_given? ? chain5(n) { |i| yield i } : chain5(n)
def chain5(n) = block_given? ? chain6(n) { |i| yield i } : chain6(n)
def chain6(n) = block_given? ? chain7(n) { |i| yield i } : chain7(n)
def chain7(n) = block_given? ? chain8(n) { |i| yield i } : chain8(n)
def chain8(n) = block_given? ? chain9(n) { |i| yield i } : chain9(n)
def chain9(n) = block_given? ? [yield(n)] : [n]
p chain0(2)
p chain0(2).size
p chain0(2) { |i| i * 5 }
