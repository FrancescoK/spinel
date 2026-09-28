class V
  attr_reader :r
  def initialize = @r = 7
  def a = 1
  def b(x) = x * 2
  def d(x, y = 1) = x + y
  def e(*r) = r
  private def c = 3
end

class W < V
  def w(k) = k + 100
end

def ev(o, sym, *args)
  args = [] if o.method(sym).arity.zero?
  o.send(sym, *args)
end

p ev(V.new, :a, 5)
p ev(V.new, :b, 5)
p ev(V.new, :c, 5)
%i[a b c d e r].each { |n| p [n, V.new.method(n).arity] }
m = V.new.method([:d].first)
p m.call(4)
p m.call(4, 4)
p V.new.method([:b].first).call(4)
p V.new.method(["r"].first).call
p W.new.method([:w].first).call(1)
begin
  V.new.method([:zz].first)
rescue NameError => e
  p [e.class, e.message]
end
begin
  W.new.method([:zz].first)
rescue NameError => e
  p [e.class, e.message]
end
