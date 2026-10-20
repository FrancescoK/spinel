# spinel: gc-stress
# A boxed receiver's writer is handed the nil of a constant Array element in
# range: a literal nil, and a nil a `map` block answers. The element needs an
# oint beside it unless it is proven no nil; read as a plain Integer it became 0.
class K; attr_accessor :a, :b; end
class J; attr_accessor :a, :b; end
def pk(i) = [K.new, J.new][i]
PAIR = [1, nil]
o = pk(0)
o.a, o.b = PAIR
p [o.a, o.b]
SQ = [1, 2].map { |x| x == 2 ? nil : x }
o2 = pk(1)
o2.a, o2.b = SQ
p [o2.a, o2.b]
class W
  def a=(v); @a = v; end
  def b=(v); @b = v; end
  def a = @a
  def b = @b
end
class V < W; end
def pw(i) = [W.new, V.new][i]
w = pw(0)
w.a, w.b = PAIR
p [w.a, w.b]
