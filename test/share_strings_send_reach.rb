# A send with a computed name reaches the receiver's class's methods (or,
# for a Symbol name on any receiver, the methods a Symbol literal names);
# what it hands them is still followed only as far as the walk sees.
class Buf
  def initialize = (@s = +"")
  def add(x) = (@s << x; self)
  def s = @s
end
class Other
  def add(x) = x.upcase
  def never_called(y) = send(y.to_s.empty? ? :add : :itself, y)
end
b = Buf.new
name = [:add, :s][0]
b.send(name, "a")
t = b.s; t << "!"
p b.s
o = Other.new
w = +"w"
r = o.send(name, w)
w << "1"
p r, w
def run(obj, m, v) = obj.public_send(m, v)
v = +"v"; run(b, :add, v); v << "2"; p b.s, v
h = [b, o].map { |x| x.send(name, +"z") }
p h.size, b.s
