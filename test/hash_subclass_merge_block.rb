# A Hash subclass instance merged with a block answers an instance of its
# class, whatever kind of Hash the block makes
class H < Hash
  attr_accessor :tag
  def hello = "hi #{size}"
end
h = H.new
h[:a] = 1
h.tag = "t"
r = h.merge({a: 2}) { |k, o, n| o + n }
p r
p r.class
p r.tag
p r.hello
r[:z] = "s"
p r
p h
c = h.merge({b: 2.5})
p c, c.class
d = h.merge({"s" => 1})
p d, d.class
e = h.dup
p e.class, e
h2 = H.new
h2[:q] = nil
p h2.compact.class, h2.compact
x = h.merge({a: 9}, {b: 8}) { |_, o, n| [o, n] }
p x, x.class
y = h.merge({a: 9}) { |*all| all }
p y
w = H.new; w[:w] = 4; m = h.merge(w) { |_, o, n| o }
p m, m.class
p h.merge({a: 5}) { |k, o, n| next 0 if o > 0; n }
class G < Hash
  def initialize; super; @n = 0; end
  attr_reader :n
end
g = G.new
g["k"] = 1.5
q = g.merge({"k" => 2.5, "j" => 1}) { |_k, a, b| a * b }
p q, q.class, q.n
q["z"] = :sym
p q.size
class I < Hash; end
i = I.new
i[1] = "x"
t = i.merge({1 => "y", 2 => "z"}) { |k, a, b| a + b + k.to_s }
p t, t.class
p i.merge({}) { 1 }.class
p h.select { |k, v| true }.class
p h.reject { |k, v| false }.class
p h.transform_values { |v| v }.class
def via_m(x) = x.merge({a: 7}) { |_, o, n| o * n }
p via_m(h), via_m(h).class
@iv = H.new
@iv[:a] = 2
p @iv.merge({a: 3}) { |_, o, n| o - n }
