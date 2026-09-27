# A lambda that constructs a value-type object returns it through the proc
# ABI's poly slot: the body boxes it and the caller unboxes it again.

class Box
  def initialize(v)
    @v = v
  end

  def v = @v
end

F = ->(v) { Box.new(v) }
p F.call("qn").v
p F.("a").v
p F["b"].v

class Cell
  def initialize(w)
    @w = w
  end

  def w = @w
end

f = ->(w) { Cell.new(w) }
p f.call("local").w

class Pt
  def initialize(x, y)
    @x = x
    @y = y
  end

  def x = @x
  def y = @y
end

G = ->(a, b) { Pt.new(a, b) }
pt = G.call(1, 2.5)
p [pt.x, pt.y]

class Tag
  def initialize(t)
    @t = t
  end

  def t = @t
end

$g = ->(t) { Tag.new(t) }
p $g.call(3).t
