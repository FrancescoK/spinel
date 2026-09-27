a, b = *[1, 2], "s"
p a, b

c, d, e = *[1, 2], "s"
p c, d, e

f, g = 0, *[1, 2]
p f, g

h, *i = *[1, 2], 3
p h, i

j, *k, l = *[1, 2], "s", :q
p j, k, l

pair = [3, 4]
m, n, o = *pair, "t"
p m, n, o

p((q, r = *[1], 2))
p q, r

A, B = *[1, 2], "s"
p A, B

class Pt
  attr_reader :x, :y
  def initialize
    @x, @y = *[1, 2], "s"
  end
end
pt = Pt.new
p pt.x, pt.y

def pick
  s, t = "x", *[1, 2]
  [s, t]
end
p pick

xs = [5]
u, v, w = *xs, 2
p u, v, w

y, z = *[1], 2
p y + z
