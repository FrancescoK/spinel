# A global that holds a Float or an Integer is boxed; its `OP=` folds
# through the boxed arithmetic like the local's. A boxed class variable
# and ivar take `%=` and `**=`, and their bitwise ops keep a Float's and
# a Bignum's value.

c = ARGV.size == 0

$f = 1.5
$f = 100 if c
$f += 2.25
p $f
$f -= 0.25
p $f
$f *= 2
p $f
$f /= 4
p $f
$f %= 7
p $f
$f **= 2
p $f
x = ($f += 1)
p x

$b = "s"
$b = 100 if c
$b <<= 3
p $b
$b >>= 1
p $b
$b |= 3
p $b
$b &= 6
p $b
$b ^= 5
p $b
y = ($b <<= 2)
p y
$b |= 2**64
p $b

def bump
  $f = 1000
  1
end
$f += bump
p $f

class K
  def initialize(c)
    @f = 1.5
    @f = 100 if c
    @b = "s"
    @b = 3 if c
  end

  def go
    @f %= 7
    p @f
    @f **= 2
    p @f
    @b |= 2**64
    p @b
  end
end
K.new(c).go

class L
  @@f = "s"
  @@b = "s"

  def self.go(c)
    @@f = 100.5 if c
    @@b = 3 if c
    @@f %= 7
    p @@f
    @@f **= 2
    p @@f
    @@b |= 2**64
    p @@b
    z = (@@b ^= 1)
    p z
  end
end
L.go(c)

$g = 1.5
$g = 1 if c
l = ->(x = ($g += ($g = 100; 2.25))) { x }
p l.call
$h = 1.5
m = ->(x = ($h += ($h = 100.0; 2.25))) { x }
p m.call
class M
  @@v = "s"

  def self.go(c)
    @@v = 1 if c
    n = ->(x = (@@v *= (@@v = 100; 3))) { x }
    p n.call
  end
end
M.go(c)
pr = proc { |x = ($g -= ($g = 100; 2))| x }
p pr.call
