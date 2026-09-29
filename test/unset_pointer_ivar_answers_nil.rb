class S
  def set(x) = @v = x
  def report = p([@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil])
end
s = S.new
s.report
s.set("hi")
s.report
class A
  def set(x) = @v = x
  def report = p([@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil])
end
a = A.new
a.report
a.set([1, 2])
a.report
class H
  def set(x) = @v = x
  def report = p([@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil])
end
h = H.new
h.report
h.set({a: 1})
h.report
class G
  def set(x) = @v = x
  def report = p([@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil])
end
g = G.new
g.report
g.set(2**70)
g.report
class O
  def set(x) = @v = x
  def report = p([@v.nil?, @v, @v.class, @v.to_s, @v.inspect, @v == nil])
end
o = O.new
o.report
o.set(S.new)
p o.instance_variable_get(:@v).class
