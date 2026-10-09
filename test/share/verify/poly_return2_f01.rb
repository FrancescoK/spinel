# minimal: poly module method, explicit fresh return through def-level ensure
module M
  def get(f)
    return @x * 2 if f
    @x
  ensure
    @n = 1
  end
end
class A; include M; def initialize(x) = @x = x; end
class B; def get(f) = "b".dup; end
src = "s".dup
os = [A.new(src), B.new]
r = os[0].get(true)
r << "!"
p r, src
