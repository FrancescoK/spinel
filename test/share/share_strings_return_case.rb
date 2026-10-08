# spinel: gc-minor
# Case arms distinguish a fresh String from the shared ivar read inside it.
class A
  def initialize(x) = @x = x
  def get(k)
    case k
    when 0 then @x
    else @x + "c"
    end
  end
end
src = "s".dup
a = A.new(src)
v = a.get(1)
v << "?"
u = a.get(0)
u << "!"
p v, u, src
