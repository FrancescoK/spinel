# A container passed to a method and kept in an ivar is widened, with the
# caller's own, by a store another method makes through the ivar
class Box
  def initialize(h)
    @h = h
  end
  def put = @h["k"] = :s
  def sym = @h[:k] = 2
  attr_reader :h
end
x = {"a" => 1}
Box.new(x).put
p x

y = {"b" => 1}
Box.new(y).sym
p y

w = {"c" => 1}
b = Box.new(w)
b.h["z"] = 1.5
p w

class Arr
  def initialize(a)
    @a = a
  end
  def add = @a << "s"
  def set = @a[0] = :t
end
z = [1]
Arr.new(z).add
p z
v = [2, 3]
Arr.new(v).set
p v
