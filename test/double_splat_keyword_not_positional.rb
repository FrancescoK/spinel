# A `**hash` into a method declaring keyword parameters is keywords, never
# one more positional argument for an optional or rest parameter.

def kn(a, b = 5, k: 1) = a + b + k
h = { k: 7 }
p kn(1, **h)
p kn(1, **{ k: 7 })
p kn(1, 2, **h)

def kl(a, b = 5, k: 1)
  x = a + b
  x + k
end
p kl(1, **h)
v = kl(1, **h)
p v
p [1, 2].map { |i| kl(i, **h) }

def knil(a, b = nil, k: 1) = [a, b, k]
p knil(1, **h)

def kr(a, *r, k: 1) = [a, r, k]
p kr(1, **h)

class C
  def m(a, b = 5, k: 1) = a + b + k
end
p C.new.m(1, **h)

# an empty hash, which types String-keyed
e = {}
p kn(1, **e)
p C.new.m(1, **e)

# a key no keyword parameter names
bad = { z: 1 }
begin
  kn(1, **bad)
rescue ArgumentError => ex
  p ex.message
end
begin
  C.new.m(1, **bad)
rescue ArgumentError => ex
  p ex.message
end
sk = { "k" => 1, "j" => 2 }
begin
  kn(1, **sk)
rescue ArgumentError => ex
  p ex.message
end

# a callee without keywords still takes the hash positionally
def opt(a, o = {}) = [a, o]
p opt(1, **h)
