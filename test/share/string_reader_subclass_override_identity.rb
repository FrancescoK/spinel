# A subclass's override of a reader that answers a String something else
# holds -- a global, a constant's field, an element, a memoized field, another
# method's -- answers that String through the ancestor's read, so a change
# through the read shows where it is held.
$g = +"glob"
class Holder; def initialize = (@v = +"held"); attr_reader :v; end
H = Holder.new
class Parent
  attr_reader :name
  def initialize = (@name = +"name")
  def change = (s = name; s << "!"; s)
end
class G < Parent
  def name = $g
end
class C < Parent
  def name = H.v
end
class E < Parent
  def initialize = (super; @arr = [+"e0"])
  def name = @arr[0]
  def arr = @arr
end
class X < Parent
  def name = (@x ||= +"kx")
end
class O < Parent
  def initialize = (super; @o = +"kid")
  def o = @o
  def name = o
end
r = G.new.change
p r, $g, r.equal?($g)
r = C.new.change
p r, H.v, r.equal?(H.v)
e = E.new
r = e.change
p r, e.arr, r.equal?(e.arr[0])
x = X.new
a = x.change
b = x.change
p a, b
o = O.new
r = o.change
p r, o.o, r.equal?(o.o)
