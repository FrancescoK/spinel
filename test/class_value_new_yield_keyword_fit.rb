# A `new` on a Class value whose keywords a yielding initialize cannot take
# builds no instance of that class, so its block says nothing about what
# that initialize yields to: a later call that does fit still compiles
# against its own block.

class A
  attr_reader :v
  def initialize(x:, y: 1) = (@v = yield(x + y) * 2)
end

class C
  attr_reader :v
  def initialize(other: 0) = (@v = other)
end

k = [A, C][ARGV.size + 1]
p k.new(other: 1) { |q| "text" }.v
k = [A, C][ARGV.size]
p k.new(x: 4) { |q| q + 1 }.v
p k.new(x: 1, y: 5) { |q| q * 3 }.v
