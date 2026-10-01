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
