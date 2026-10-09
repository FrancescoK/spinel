# case value assigned to a local, local is the tail
module M
  def get(k)
    v = case k
        when 1 then @x
        else @x + "c"
        end
    v
  end
  def get2(k)
    v = begin
      raise "x" if k == 0
      @x
    rescue
      @x + "r"
    end
    v
  end
end
class A; include M; def initialize(x) = @x = x; end
class B; def get(k) = "b".dup; def get2(k) = "d".dup; end
src = "s".dup
a = A.new(src)
r = a.get(2); r << "!"
q = a.get2(0); q << "?"
p r, q, src
os = [A.new(src), B.new]
r = os[0].get(2); r << "!"
q = os[0].get2(0); q << "?"
p r, q, src
u = os[0].get(1); u << "#"
w = os[0].get2(1); w << "%"
p u, w, src
