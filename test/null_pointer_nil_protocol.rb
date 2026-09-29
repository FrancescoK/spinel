class O; end
class A
  def set(x) = @v = x
  def r = [@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil, "#{@v}"]
end
class H
  def set(x) = @v = x
  def r = [@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil, "#{@v}"]
end
class OA
  def set(x) = @v = x
  def r = [@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil, "#{@v}"]
end
class SA
  def set(x) = @v = x
  def r = [@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil, "#{@v}"]
end
class FA
  def set(x) = @v = x
  def r = [@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil, "#{@v}"]
end
class SH
  def set(x) = @v = x
  def r = [@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil, "#{@v}"]
end
class PR
  def set(x) = @v = x
  def r = [@v.nil?, @v.class, @v == nil]
end
class RX
  def set(x) = @v = x
  def r = [@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil, "#{@v}"]
end
class BI
  def set(x) = @v = x
  def r = [@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil, "#{@v}"]
end
class ST
  def set(x) = @v = x
  def r = [@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil, "#{@v}"]
end
a = A.new; p a.r; a.set([1])
h = H.new; p h.r; h.set({a: 1})
oa = OA.new; p oa.r; oa.set([O.new])
sa = SA.new; p sa.r; sa.set(["s"])
fa = FA.new; p fa.r; fa.set([1.5])
sh = SH.new; p sh.r; sh.set({"k" => "v"})
rx = RX.new; p rx.r; rx.set(/x/)
bi = BI.new; p bi.r; bi.set(2**70)
st = ST.new; p st.r; st.set("s")
pr = PR.new; p pr.r; pr.set(-> { 1 })
h = {"a" => "x"}
p h["b"].class, h["a"].class
p "abc".class, [1].to_s, {a: 1}.to_s, /r/.to_s, (2**70).class, [1, 2].class
x = [1, 2]
p x.to_s, x.class, "#{x}", x == nil, x != nil
m = "abc".match(/z/)
p m.class
def maybe(f) = f ? [1] : nil
p maybe(false).to_s, maybe(true).to_s
$g = nil
def setg = $g = [3]
p $g.to_s, $g.class, "#{$g}"
setg
p $g.to_s, $g.class
class R
  def set = @r = /ab/
  def r = [@r.to_s, @r.inspect, @r == nil, @r != nil, @r.class, "#{@r}"]
end
rr = R.new
p rr.r
rr.set
p rr.r
class B
  def set = @b = 2**70
  def r = [@b == nil, @b != nil, @b.class, @b.to_s, "#{@b}"]
end
bb = B.new
p bb.r
bb.set
p bb.r
class HH
  def set = @h = {"k" => 1}
  def r = [@h.to_s, "#{@h}", @h.class, @h == nil, @h != nil]
end
hh = HH.new
p hh.r
hh.set
p hh.r
