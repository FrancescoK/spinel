# handles in many holder kinds, churned under allocation
class Box
  attr_reader :v
  def initialize(v) = (@v = v)
  def grow(n) = (n.times { |i| @v << i.to_s }; @v)
end
S = Struct.new(:a, :b)
$g = +"g"
@iv = +"iv"
def churn(n) = Array.new(n) { |i| "x#{i}" * 3 }.join.size
base = +"b"
alias_b = base
arr = [base, $g, @iv]
h = {k: base, g: $g}
box = Box.new(base)
st = S.new(base, $g)
pr = proc { |x| x << "p" }
20.times do |i|
  churn(50)
  arr[i % 3] << "a"
  h[:k] << "h"
  box.grow(1)
  st.a << "s"
  pr.call(alias_b)
  $g << "!"
  @iv << "?"
end
p base.size, alias_b.equal?(base), arr[0].equal?(base), h[:k].equal?(base), box.v.equal?(base), st.a.equal?(base)
p $g.size, @iv.size, st.b.equal?($g), h[:g].equal?($g)
p base[0, 30]
