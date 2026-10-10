# A parenthesized sequence stored into a String instance variable (an
# attribute writer, a Struct or Data member, `@r = (...)`) runs the
# statements before its value, and its value is the last one: nil when it
# ends in nil. They were dropped, and `@r = (puts "side"; nil)` raised
# TypeError.
class H
  attr_accessor :r

  def initialize = (@r = +"ab"; @r << "!")
  def a = (@r = (puts "a"; nil); @r)
  def b = (@r = (puts "b1"; (puts "b2"; nil)); @r)
  def c = (@r = (nil); @r)
  def d = (x = (@r = (puts "d"; nil)); [x, @r])
  def e = (@r = (@q = 5; nil); [@q, @r])
  def f = (@r = (puts "f"; +"zz"); @r << "?"; @r)
end
p H.new.a
p H.new.b
p H.new.c
p H.new.d
p H.new.e
p H.new.f

h = H.new
h.r = (puts "w"; nil)
p h.r
h = H.new
h.r = (puts "w1"; (puts "w2"; nil))
p h.r
h = H.new
h.r = (nil)
p h.r
h = H.new
h.r = (puts "v"; +"str")
h.r << "?"
p h.r

S = Struct.new(:a)
x = S.new(+"q")
x.a << "!"
p S.new((puts "s"; nil)).a
p S.new((puts "t"; +"tt")).a
D = Data.define(:a)
p D.new((puts "dd"; nil)).a
