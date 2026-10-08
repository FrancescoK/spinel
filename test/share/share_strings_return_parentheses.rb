# spinel: gc-minor
# Parenthesized conditionals keep their leaves in return position.
class A
  def initialize(x) = @x = x
  def get(k) = k == 0 ? @x : (k == 1 ? @x : @x + "p")
end
src = "s".dup
a = A.new(src)
v = a.get(2)
v << "?"
p v, src
class A
  def explicit(k)
    return (k == 0 ? @x : (k == 1 ? @x : @x + "r"))
  end
end
u = a.explicit(2)
u << "!"
p u, src
