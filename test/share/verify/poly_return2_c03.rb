# explicit return of fresh derived value through ensure, poly, various ops
module M
  def g1(f)
    return @x.upcase if f
    @x
  ensure
    @n = 1
  end
  def g2(f)
    return "<#{@x}>" if f
    @x
  ensure
    @n = 1
  end
  def g3(f)
    return @x * 2 if f
    @x
  ensure
    @n = 1
  end
end
class A; include M; def initialize(x) = @x = x; end
class B; def g1(f) = "b".dup; def g2(f) = "c".dup; def g3(f) = "d".dup; end
src = "s".dup
os = [A.new(src), B.new]
a = os[0].g1(true); a << "1"
b = os[0].g2(true); b << "2"
c = os[0].g3(true); c << "3"
p a, b, c, src
