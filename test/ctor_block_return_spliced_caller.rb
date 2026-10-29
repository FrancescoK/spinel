# A `return` in a block given to `new`, whose initialize yields, leaves the
# method the block is written in, also when that method is itself spliced
# into its caller because it yields (#10514).
class Box
  def initialize(n)
    @n = n
    yield self if block_given?
  end
  attr_reader :n
end

def with
  Box.new(1) do |b|
    return yield b
  end
  puts "not reached"
end

def with_local
  Box.new(2) do |b|
    v = yield b
    return v
  end
  puts "not reached"
end

# no yield of its own: the method is not spliced
def plain
  Box.new(3) do |b|
    return b.n * 2
  end
  puts "not reached"
end

# the return taken only on one path
def maybe(flag)
  Box.new(4) do |b|
    return yield(b) if flag
  end
  :fell_through
end

# a splice inside a splice
def outer
  inner { |x| return x + 100 }
  :not_reached
end

def inner
  Box.new(5) { |b| yield b.n }
  :inner_done
end

p with { |b| b.n + 10 }
p with_local { |b| b.n + 20 }
p plain
p maybe(true) { |b| b.n + 30 }
p maybe(false) { |b| b.n + 30 }
p outer
puts "after"
