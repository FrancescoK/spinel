# A String method that answers its receiver, over a receiver that is no
# variable (`(@s << x).bytesplice(0..0, y)`), as an argument of `p` taken
# as a value, which runs its arguments ahead of each other: the receiver
# runs once (tick counts each `<<`), and the box takes the handle that run
# answered. The same operands in an Array or Hash literal and as a method's
# arguments, which took the handle already, stay right.
$n = 0
def tick(x) = ($n += 1; x)
def show(a, b) = p(a, b)
class Box
  @@c = +"cv"
  def initialize; @s = +"ab"; end
  def go; p (@s << tick("z")).bytesplice(0..0, "R"), @s; end
  def ins = (p (@s << tick("y")).insert(1, "I"), @s)
  def cv = [(@@c << tick("x")).prepend("P"), @@c]
end
p Box.new.go, $n
b = Box.new
p b.ins, b.cv, $n
$g = +"gl"
x = (p ($g << tick("z")).concat("C"), $g)
p x, $n
x = (p ($g << tick("y")).force_encoding("ASCII-8BIT"), $g)
p x, $n
p({a: ($g << tick("x")).replace("new"), b: $g}, $n)
show(($g << tick("w")).bytesplice(0, 1, "Q"), $g)
p $n
class Holder
  attr_accessor :s
  def initialize; @s = +"at"; end
end
$o = Holder.new
show(($o.s << tick("v")).insert(0, "<"), $o.s)
p $n
