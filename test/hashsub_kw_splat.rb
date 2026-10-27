# A Hash subclass instance is a Hash already: `**h` splats its own pairs.
# CRuby never calls the class's own #to_hash there. Spinel splatted no
# pairs, or the #to_hash answer.
class H < Hash; end
class T < Hash
  def to_hash = {z: 0}
end

def kw(**o) = o
def k2(a: 0, **o) = [a, o]
def req(a:) = a

h = H.new
h[:a] = 1
t = T.new
t[:a] = 2

p kw(**h)
p k2(**h)
p req(**h)
p({b: 2, **h})
p kw(**h, c: 3)
p kw(**t)
p({b: 2, **t})
def fwd(x) = kw(**x)
p fwd(h)
2.times { p kw(**t) }

P = Struct.new(:a, keyword_init: true)
p P.new(**h)

def pick(h, f) = f ? h : nil
p kw(**pick(h, true))
p kw(**pick(h, false))
