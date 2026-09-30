# A builtin receiver in a slot of no single type keeps its own methods
# when a user class defines the same name at another arity: arguments,
# in-place mutation, a block, each argument evaluated once.

class Painter
  def fill(left, top, width, height, rgb) = [left, top, width, height, rgb]
  def rotate(a, b) = :painter_rotate
  def take(a, b) = :painter_take
  def inject(a, b, c) = :painter_inject
end

class Bus
  def initialize(flag)
    @pages = flag ? Array.new(4, 0) : [nil, "x", 1, 2]
  end

  def map(rom) = @pages.fill(rom, 1, 2)
  def fill1(v) = @pages.fill(v)
  def fill2(v) = @pages.fill(v, 3)

  def fill_stmt(v)
    @pages.fill(v, 2, 1)
    @pages
  end

  def rot(n) = @pages.rotate(n)
  def tk(n) = @pages.take(n)
  def sizes = @pages.inject(0) { |s, x| s + x.to_s.size }
end

p Bus.new(true).map(7)
p Bus.new(false).map(8)
p Painter.new.fill(1, 2, 3, 4, 5)

[true, false].each do |f|
  b = Bus.new(f)
  p b.fill1(3)
  p b.fill2(4)
  p b.fill_stmt(5)
  p b.rot(1)
  p b.tk(2)
  p b.sizes
end

$calls = 0
def next_val
  $calls += 1
  $calls * 10
end

def local_fill(v)
  v.fill(next_val, 1, 1)
  v
end
p local_fill([1, 2, 3])
p local_fill([nil, :a, "b"])
p $calls
