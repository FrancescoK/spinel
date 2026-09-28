# Hash#store through a parameter whose callers pass hashes of different kinds
def m(h)
  h.store(1, "one")
end
x = {1 => 2}
y = {"a" => 3}
m(x); m(y)
p x, y

def f(h, a, b) = h.store(a, b)
z = {}
f(z, :k, 1)
p z

def g(h) = h.store(:s, [1])
p g({"a" => 1})
p g({2 => 2.5})
