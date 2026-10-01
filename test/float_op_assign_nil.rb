# A nil in a Float slot is a NaN payload every C operator carries through,
# so `x += 1` on a nil Float answered nil where `x + 1` raises
# NoMethodError, and `x += y` with y nil answered nil where it raises
# TypeError. The op-assign tests the slot and the rhs as the binary form
# does, wherever either can hold nil: a local, a global, a class variable,
# an ivar.

def try
  yield
rescue NoMethodError, TypeError => e
  puts e.class
end

def local(xv, y)
  x = xv
  x += y
  p x
end
try { local(1.5, 2) }
try { local(nil, 2) }
try { local(1.5, nil) }

def ops(xv)
  x = xv
  x -= 0.5
  x *= 2
  x /= 4
  x %= 1
  x **= 2
  p x
end
try { ops(2.5) }
try { ops(nil) }

def int_rhs(xv, n)
  x = xv
  x += n
  p x
end
try { int_rhs(1.5, 2) }
try { int_rhs(1.5, nil) }

def glob(v)
  $g = v
  $g += 1
  p $g
  p($g -= 1)
end
try { glob(1.5) }
try { glob(nil) }

class K
  @@c = 0.5
  def self.set(v) = (@@c = v)

  def self.bump
    @@c += 1
    p @@c
  end

  def initialize(v) = (@x = v)

  def ibump
    @x += 1
    p @x
  end
end
try { K.set(1.5); K.bump }
try { K.set(nil); K.bump }
try { K.new(1.5).ibump }
try { K.new(nil).ibump }

# a slot that is never nil keeps the plain operator
s = 0.5
3.times { s += 0.25 }
p s

# an element read in a loop that holds the array's header: in range of an
# array with no nil it is a plain load, and past the end, or in an array a
# computed index left a gap in, its nil raises with the slot as it was
def sum_to(a, n)
  s = 0.0
  i = 0
  while i < n
    s += a[i]
    i += 1
  end
  s
end
a = [1.5, 2.5]
try { p sum_to(a, 2) }
try { p sum_to(a, 3) }
g = [1.0, 2.0]
k = a.size + 1
g[k] = 4.0
try { p sum_to(g, 2) }
try { p sum_to(g, 4) }

# NaN arithmetic with no nil in it goes on
t = 1.0
t += 0.0 / 0.0
p t.nan?
u = Float::INFINITY
u -= Float::INFINITY
p u.nan?

# a loop bounded by the array's own size reads in range, and still meets the
# nil a gap left
def total(a)
  s = 0.0
  i = 0
  while i < a.size
    s += a[i]
    i += 1
  end
  s
end
try { p total([1.5, 2.5]) }
h = [1.0]
h[a.size] = 4.0
try { p total(h) }

# an accessor's op-assign takes its backing ivar's nil the same way, through
# a typed receiver and through the dispatch on a boxed one
class Acc
  attr_accessor :x
  def initialize(v) = (@x = v)
end
try { a = Acc.new(1.5); a.x += 1.0; p a.x }
try { b = Acc.new(nil); b.x += 1.0; p b.x }
class AccB
  attr_accessor :y
  def initialize(v) = (@y = v)
end
class AccC
  attr_accessor :y
  def initialize(v) = (@y = v)
end
AccC.new(4.5)
[AccB.new(2.5), AccC.new(nil), AccC.new(1.5)].each { |o| try { o.y += 1.0; p o.y } }
