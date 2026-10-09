# spinel: gc-minor
# poly, begin/else arm fresh, rescue modifier
module M
  def get(f)
    begin
      raise "x" if f
    rescue
      @x
    else
      @x + "e"
    end
  end
  def get2(f) = (f ? raise("x") : @x) rescue @x + "m"
end
class A; include M; def initialize(x) = @x = x; end
class B; def get(f) = "b".dup; def get2(f) = "c".dup; end
src = "s".dup
os = [A.new(src), B.new]
w = [os[0].get(true), os[0].get(false), os[0].get2(true), os[0].get2(false), os[1].get(1), os[1].get2(1)]
w[1] << "?"
w[2] << "#"
w[0] << "!"
p w, src
