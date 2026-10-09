# A String held as a growable buffer, an append accumulator or a parameter
# typed from a handle argument, handed to a method that appends to its
# parameter keeps the append.
# spinel: gc-minor
# spinel: share
def grow(v) = v << "x"

s = +""
3.times { |i| s << i.to_s }
grow(s)
p s

t = +""
[1, 2].each { |i| t << i.to_s }
grow(t)
p t

def build
  u = +""
  4.times { |i| u << i.to_s }
  grow(u)
  u
end
p build

def hand_on(a, b) = (grow(a); [a, b])
w = +"s1"
p [method(:hand_on).call(*[w, 2]), w]
