# bare descendant call whose String result is the handle; something in between
class Base
  def tick
    r = bump
    other
    r
  end
  def tock = bump
  def tack(v) = v ? bump : "lit"
end
class Leaf < Base
  def initialize = (@buf = +"L"; @o = +"O")
  def bump = @buf
  def other = @o
  def buf = @buf
end
class Leaf2 < Base
  def initialize = @buf = +"M"
  def bump = @buf
  def other = "z"
  def buf = @buf
end
l = Leaf.new
t = l.tick
t << "x"
u = l.tock
u << "y"
w = l.tack(true)
w << "w"
p l.buf
m = Leaf2.new
q = m.tock
q << "q"
p m.buf
k = [l, m][1]
z = k.tick
z << "k"
p m.buf, k.tack(false)
