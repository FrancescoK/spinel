# Multiple assignment of Strings under one String representation, where a
# String is held as its handle: the rest of a list collected into a String
# Array was handed the handle where the Array keeps the bytes, an ivar
# target from a String Array was handed the bytes where the field keeps the
# handle, and a user `[]=` target's literal key the bytes where the
# parameter takes the handle. Each failed to compile.
class C
  def initialize = @h = {}
  def []=(k, v)
    @h[k] = v
  end
  def show = p(@h)
end
c = C.new
c["a"], c["b"] = [1.5]
s = +"s"
s << "!"
a, *b = 1, s
p a, b
c.show
s = +"s"; t = +"t"
x, *y = s, t, +"u"
y[0] << "!"
p t, y
*z, w = s, +"v"
p z, w
ARR = [+"a", +"b"]
$g1, $g2 = ARR
$g1 << "?"
p ARR, $g1, $g2
class K
  def set = (@x, *@y = ARR)
  def show = p(@x, @y)
end
k = K.new; k.set; k.show
