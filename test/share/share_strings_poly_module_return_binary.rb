# spinel: gc-minor
# binary and frozen returns
module M
  def get(k)
    k == 0 ? @x : (k == 1 ? @f : @x.b)
  end
end
class A; include M; def initialize(x, f) = (@x = x; @f = f); end
class B; def get(k) = "b".dup; end
src = "\xff\x00s".b
os = [A.new(src, "fro"), B.new]
w = [os[0].get(0), os[0].get(1), os[0].get(2), os[1].get(0)]
p w.map(&:encoding), w.map(&:frozen?), w.map(&:bytesize)
w[0] << "!"
begin; w[1] << "x"; rescue FrozenError; puts "frozen"; end
w[2] << "?"
p w, src
