# spinel: gc-minor
# A module arm preserves only the handle of the value returned through ensure.
module DeferredModule
  def get(k)
    return @x * 2 if k == 0
    return @x.upcase if k == 1
    return "<#{@x}>" if k == 2
    return nil if k == 3
    return if k == 4
    @x
  ensure
    @n = @y.size
  end
  def yielding(f)
    return @x + "y" if f
    yield
    @x
  ensure
    @n = @y.size
  end
end
class DeferredA
  include DeferredModule
  def initialize(x, y)
    @x = x
    @y = y
  end
end
class DeferredB
  def get(k) = "b".dup
  def yielding(f) = "b".dup
end
src = "s".dup
other = "o".dup
os = [DeferredA.new(src, other), DeferredB.new]
a = os[0].get(0)
a << "0"
b = os[0].get(1)
b << "1"
c = os[0].get(2)
c << "2"
p a, b, c, os[0].get(3), os[0].get(4), src, other
d = os[0].yielding(true) { }
d << "y"
p d, src, other
e = os[0].get(5)
e << "!"
f = os[0].yielding(false) { }
f << "?"
p e, f, src, other, os[1].get(0)
