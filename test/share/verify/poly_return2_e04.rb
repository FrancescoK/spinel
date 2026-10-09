# next with fresh value in a yielding method's block, result shared
module M
  def get(f)
    r = yield(@x)
    f ? r : @x
  end
end
class A; include M; def initialize(x) = @x = x; end
class B; def get(f) = "b".dup; end
src = "s".dup
os = [A.new(src), B.new]
q = os[0].get(true) { |s| next s + "n" if s.size > 0; s }; q << "?"
p q, src
u = os[0].get(true) { |s| s }; u << "#"
p u, src
