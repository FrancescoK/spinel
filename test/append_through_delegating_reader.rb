# An append through a value many classes hand on by the same name
# (`def peek(i) = @nxt.peek(i)`, a bus of devices) follows each method
# once: followed through every class at every level, the compile ran
# for minutes, and for hours on a larger program.

class Leaf
  def initialize = @v = [+"leaf"]
  def peek(i) = @v[i]
end

class Dev0
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev1
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev2
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev3
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev4
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev5
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev6
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev7
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev8
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev9
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev10
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev11
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev12
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev13
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev14
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev15
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev16
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev17
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev18
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev19
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev20
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev21
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev22
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev23
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev24
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev25
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev26
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev27
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev28
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev29
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev30
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

class Dev31
  def initialize(nxt) = @nxt = nxt
  def peek(i) = @nxt.peek(i)
end

kinds = [Dev0, Dev1, Dev2, Dev3, Dev4, Dev5, Dev6, Dev7, Dev8, Dev9, Dev10, Dev11, Dev12, Dev13, Dev14, Dev15, Dev16, Dev17, Dev18, Dev19, Dev20, Dev21, Dev22, Dev23, Dev24, Dev25, Dev26, Dev27, Dev28, Dev29, Dev30, Dev31]
bus = Leaf.new
kinds.each { |k| bus = k.new(bus) }
bus.peek(0) << "!"
p bus.peek(0)
p kinds.size
