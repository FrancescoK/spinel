# A yield whose blocks answer different types at different call sites,
# its value written to an instance, global or class variable (directly or
# through a conditional) or put in an array literal.

class B
  def initialize(x)
    @x = x
    @y = block_given? ? yield(x) : "nil"
  end

  def to_s = "B(#{@x},#{@y})"
end

puts B.new(8) { |v| "blk#{v}" }.to_s
puts B.new(9) { |v| v }.to_s
puts B.new(7).to_s

class C
  @@last = nil

  def m(x)
    @z = [yield(x)]
    @z
  end

  def g(x)
    $g = yield(x)
    $g
  end

  def k(x)
    @@last = (x > 0 && yield(x))
    @@last
  end

  def o(x)
    @o ||= yield(x)
    @o
  end
end

c = C.new
p c.m(1) { |v| "s#{v}" }
p c.m(2) { |v| v * 2 }
p c.g(1) { |v| "s#{v}" }
p c.g(2) { |v| v * 2 }
p c.k(1) { |v| "s#{v}" }
p c.k(2) { |v| v * 2 }
p C.new.o(3) { |v| "s#{v}" }
p C.new.o(4) { |v| v + 1 }
