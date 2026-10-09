# chains of methods mixing fresh and shared
module M
  def raw = @x
  def fr = @x + "f"
  def mix(f) = f ? raw : fr
  def mix2(f) = f ? fr : mix(true)
  def mix3(f) = mix2(f)
end
class A; include M; def initialize(x) = @x = x; end
class B; def mix(f) = "b".dup; def mix2(f) = "c".dup; def mix3(f) = "d".dup; end
src = "s".dup
os = [A.new(src), B.new]
w = [os[0].mix(true), os[0].mix(false), os[0].mix2(true), os[0].mix2(false), os[0].mix3(true), os[0].mix3(false), os[1].mix3(1)]
w[1] << "1"
w[2] << "2"
w[4] << "4"
p w, src
w[0] << "0"
p w, src
