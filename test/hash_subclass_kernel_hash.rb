# Kernel#Hash answers a Hash subclass instance as it is: CRuby never calls
# its own #to_hash, and a nil still answers a new {}.
class H < Hash
  def tag = "H#{size}"
  def conv = Hash(self)
end

class G < Hash
  def to_hash = {z: 9}
end

class Box
  def initialize(h) = @h = h
  def conv = Hash(@h)
end

def via(x) = Hash(x)

h = H.new
h[:a] = 1
y = Hash(h)
y[:b] = 2
p h
p y.tag
p y.equal?(h)
p h.conv.equal?(h)
p Box.new(h).conv.equal?(h)
p via(h).class
p Kernel.Hash(h).class

g = G.new
g[:k] = 1
p Hash(g)
p Hash(g).class

3.times { |i| h[i] = i; p Hash(h).size }
[h, nil].each { |e| p Hash(e) }

q = nil
q = h if h.size > 2
p Hash(q).class
r = nil
r = h if h.size > 99
p Hash(r)
p Hash(nil)

f = H.new.freeze
p Hash(f).frozen?
