# A nil element of a literal right side widens its target the way `x = nil`
# does, so a constant after the splat gets a slot and a local, instance,
# global or class variable or attribute typed elsewhere still reads nil.
M, *n, O = "a", :b, 3.0, nil
p M, n, O

i = 1
i, j = nil, 2
p i, j

f = 1.5
k, *r, f = 1, 2, nil
p f, k, r

s = "s"
s, t = nil, "t"
p s, t

class Point
  def initialize
    @x = 0
    @y = 0.5
  end

  def clear
    @x, @y = nil, nil
    p @x, @y
  end
end
Point.new.clear

$lo = 3
$hi = 4
$lo, *rest, $hi = 1, 2, nil
p $lo, rest, $hi

class Tally
  @@a = 0
  @@b = 0
  @@a, *mid, @@b = 1, 2, nil
  p @@a, mid, @@b
end

class Box
  attr_accessor :v, :w
end
bx = Box.new
bx.v = 5
bx.v, bx.w = nil, 6
p bx.v, bx.w
