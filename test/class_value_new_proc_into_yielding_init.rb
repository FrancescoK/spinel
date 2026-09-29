# A Class value's `new` handed a proc (`&pr`, `&nil`, a forwarded `&b`, or
# the block a `...` forward carries) where one candidate's initialize yields.

class A
  def initialize(x, k: 0) = (@x = x; @k = k)
  def to_s = "A(#{@x},#{@k})"
end

class B
  def initialize(x, k: 0) = (@x = x; @k = k; @y = block_given? ? yield(x) : "nil")
  def to_s = "B(#{@x},#{@k},#{@y})"
end

TYPES = { 0 => A, 1 => B }.freeze

pr = proc { |v| v * 3 }
puts TYPES.fetch(1).new(2, &pr).to_s
puts TYPES.fetch(0).new(2, &pr).to_s
puts TYPES.fetch(1).new(2, &nil).to_s
puts TYPES.fetch(1).new(2, k: 5, &pr).to_s

def dyn(s, *a, **h, &b) = TYPES.fetch(s).new(*a, **h, &b)
def dyn3(s, *a, &b) = TYPES.fetch(s).new(*a, &b)

puts dyn(0, 3, k: 4).to_s
puts dyn(1, 5) { |v| v * 2 }.to_s
puts dyn3(0, 7).to_s
puts dyn3(1, 7).to_s
puts dyn3(1, 8) { |v| v + 1 }.to_s

$sel = 0
class Factory
  def self.build(...)
    klass = TYPES.fetch($sel)
    klass.new(...)
  end
end

puts Factory.build(1, k: 2).to_s
$sel = 1
puts Factory.build(3).to_s
puts Factory.build(4) { |v| "blk#{v}" }.to_s
