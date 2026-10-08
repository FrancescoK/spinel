# spinel: gc-minor
# poly, case arm fresh
module M
  def get(k)
    case k
    when 0 then @x
    when 1 then @x + "c"
    else @x.upcase
    end
  end
end
class A; include M; def initialize(x) = @x = x; end
class B; def get(k) = "b".dup; end
src = "s".dup
os = [A.new(src), B.new]
w = [os[0].get(0), os[0].get(1), os[0].get(2), os[1].get(0)]
w[0] << "!"
w[1] << "?"
w[2] << "#"
p w, src
