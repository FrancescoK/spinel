# `%=` and `**=` on a Float slot: floored modulo taking the divisor's sign,
# and the power, on every kind of slot and in value position.
f = 10.5
f %= 7
p f
f **= 2
p f
g = -5.5
g %= 2
p g
g = 5.5
g %= -2.0
p g
h = 2.0
p(h **= 0.5)
p(h %= 1.0)

$g = 7.5
$g %= 2
p $g
p($g **= 3)

class C
  @@c = 9.0
  attr_accessor :x
  def initialize; @x = 8.5; end
  def run
    @x %= 3
    p @x
    @x **= 2
    p @x
    p(@x %= 5.0)
    @@c %= 4
    p @@c
    @@c **= 0.5
    p(@@c **= 2)
  end
end
o = C.new
o.run
o.x %= -2
p o.x
o.x **= 2
p o.x

a = [1.5, 2.5, 9.0]
a[0] %= 1.0
a[1] %= -2
a[2] **= 0.5
p a
s = {"k" => 7.5}
s["k"] %= -2
s["k"] **= 2
p s

def two = 2
z = 6.5
z %= two
p z
begin
  q = 1.0
  q %= 0
rescue ZeroDivisionError => e
  p e
end
