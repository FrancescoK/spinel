# case value used as an argument and in interpolation, then shared tail
module M
  def get(k)
    t = "<" + (case k when 1 then @x else "z" end)
    @y = t
    k == 3 ? t : @x
  end
end
class A; include M; def initialize(x) = @x = x; end
class B; def get(k) = "b".dup; end
src = "s".dup
os = [A.new(src), B.new]
r = os[0].get(1); r << "!"
p r, src
q = os[0].get(3); q << "?"
p q, src
