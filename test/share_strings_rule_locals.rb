# The rule shares a String local, parameter or ivar that a second name sees
# and one of them changes: each name reads the change. A String no second
# name sees stays a plain String.
s = +"a"
t = s
t << "b"
p s, s.equal?(t)

def grow(x) = x << "!"
u = +"u"
grow(u)
grow(u)
p u

class Box
  def initialize(v) = @v = v
  def add(x) = (@v << x; self)
  def v = @v
end
w = +"w"
b = Box.new(w)
b.add("1").add("2")
p w, b.v

q = +"q"
q << "only"
p q
