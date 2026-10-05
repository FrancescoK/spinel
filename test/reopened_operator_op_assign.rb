# `t op= x` is `t = t op x`, so a program that reopens a builtin class with
# its own operator gets that method through the operator-write too, as CRuby
# does: with `Integer#+` reopened, `v = 1; v += 2` answers the reopening's 42,
# not 3. Every target form: a local, an ivar, a class variable, a global, an
# Array element, an attribute (an accessor and a hand-written writer), and
# an Integer, a Float and a String operator.
class Integer
  def +(o) = 42
  def -(o) = 41
  def *(o) = 40
  def /(o) = 39
  def %(o) = 38
  def <<(o) = 37
  def >>(o) = 36
  def &(o) = 35
  def |(o) = 34
  def ^(o) = 33
end

class Float
  def +(o) = 1.25
end

class String
  def +(o) = "plus"
  def *(o) = "times"
end

class Pt
  attr_accessor :x
  def initialize = @x = 1
end

class W
  def initialize = @v = 1
  def v = @v
  def v=(n)
    @v = n
  end
end

class Counter
  @@n = 1
  def self.bump = (@@n -= 1)

  def initialize = @i = 1
  def step = (@i *= 2; @i)
end

a1 = 7; a1 += 1; p a1
a2 = 7; a2 -= 1; p a2
a3 = 7; a3 *= 1; p a3
a4 = 7; a4 /= 1; p a4
a5 = 7; a5 %= 1; p a5
a6 = 7; a6 <<= 1; p a6
a7 = 7; a7 >>= 1; p a7
a8 = 7; a8 &= 1; p a8
a9 = 7; a9 |= 1; p a9
a10 = 7; a10 ^= 1; p a10

f = 1.5; f += 2.0; p f
s = "a"; s += "b"; p s
t = "a"; t *= 3; p t

p Counter.bump
p Counter.new.step
$g = 1; $g += 1; p $g

# the receiver and the key are evaluated once
def key = (puts "key"; 0)
def arr(a) = (puts "arr"; a)
xs = [1, 2]; arr(xs)[key] += 5; p xs
fs = [1.0]; fs[0] += 1.0; p fs

pt = Pt.new; pt.x += 1; p pt.x
pts = [Pt.new]; pts[0].x -= 1; p pts[0].x
w = W.new; w.v += 1; p w.v

# in value position, and on a parameter
b = 1
p(b += 1)
def bump(n) = (n += 1; n)
p bump(1)
