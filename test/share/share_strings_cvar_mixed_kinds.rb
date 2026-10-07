# Flag-only: one class variable name holding a String in one class and a
# String Array in another. The share facts key class variables by name, so
# the rule shares both as one holder: the String takes the handle and the
# Array, a typed String Array, holds its Strings as handles too, whichever
# class declares it first; a typed one left over is refused at the seal.
# And a global's, a constant's or a class variable's Array whose elements
# the rule shares, written from a new String Array (`s.split`), holds each
# String as a handle of its own, as a local's does: a change through an
# element read from it was lost.
class B
  @@x = "p q".split(" ")
  def self.x = @@x
end
class A
  @@x = +"a"
  def self.x = @@x
end
t = A.x
t << "?"
u = B.x[0]
u << "!"
p A.x, B.x
$g = "g h".split(" ")
v = $g[0]
v << "!"
p $g
K = "k l".split(" ")
w = K[1]
w << "!"
p K
class C
  @@y = "c d".split(" ")
  def self.f = (z = @@y[0]; z << "!"; @@y)
end
p C.f
