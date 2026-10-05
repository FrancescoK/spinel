# each_pair on a boxed receiver binds its key and value boxed, as each
# does. A method whose Hash parameter one site fills with Symbol keys and
# another (through a forwarding method) with String keys walked the second
# Hash with the key typed as the first's Symbol, and the String key read as
# a Symbol: {"d" => 4} came out as {"" => 4}.
def upd(other, out)
  other.each_pair { |key, value| out[key.to_s] = value }
  out
end
def via(h, out) = upd(h, out)
o = {}
via({c: 3, "d" => 4}, o)
upd({e: 5}, o)
p o

class Store
  def initialize(src = nil)
    @h = {}
    update(src) if src
  end
  def update(other)
    other.each_pair { |k, v| @h[k.to_s] = v }
    self
  end
  attr_reader :h
end
s = Store.new({a: 1, "b" => 2, 3 => :c})
s.update({"x" => 9})
p s.h
p Store.new.update(z: nil).h
