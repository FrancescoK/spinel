# spinel: gc-minor
# rescue/ensure
module M
  def get(f)
    begin
      raise "x" if f
      @x
    rescue
      @x + "r"
    ensure
      @x.size
    end
  end
end
class A; include M; def initialize(x) = @x = x; end
class B; def get(f) = "b".dup; end
src = "s".dup
os = [A.new(src), B.new]
w = [os[0].get(false), os[0].get(true), os[1].get(true)]
w[0] << "!"
w[1] << "?"
p w, src
