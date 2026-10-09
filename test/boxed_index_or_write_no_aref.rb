# `r[k] ||= v` on a receiver known only at run time reads r[k] first: an
# object whose class defines []= but no [] raises NoMethodError before the
# store, as CRuby does. The read answered nil and the store ran. A Struct's
# members and a class's own [] still answer.
class C
  attr_reader :v
  def []=(k, v)
    @v = v
  end
end
b = [C.new, 1].first
begin
  b["k"] ||= 1
  p :no_raise
rescue NoMethodError => e
  p e.message
end
p b.v
S = Struct.new(:a, :b)
s = [S.new(1, 2), 1].first
p s[:a], s["b"], s[0]
s[:a] ||= 5
p s
class D
  def [](k) = k * 2
end
d = [D.new, 1].first
p d[3]
