# method also called with a block
module M
  def get(f)
    v = block_given? ? yield(@x) : @x
    f ? v : v + "f"
  end
end
class A; include M; def initialize(x) = @x = x; end
class B; def get(f) = "b".dup; end
src = "s".dup
os = [A.new(src), B.new]
r1 = os[0].get(true)
r2 = os[0].get(false)
r3 = os[0].get(true) { |s| s }
r4 = os[0].get(true) { |s| s + "k" }
r2 << "2"
r4 << "4"
p r1, r2, r3, r4, src
r1 << "1"
p r1, r3, src
