# A splat of a local spreads as many arguments as the Array holds when the
# call runs. A push through an alias of the local (`b = a; b << x`), or
# through a method or container it was handed to, changes that count.
def t
  yield
rescue ArgumentError, TypeError => e
  p [e.class, e.message]
end
a = [5]
b = a
b << 6
t { p Hash.new(*a)[:y] }
c = ["x"]
d = c
d << "!"
t { p "a-b".split(*c) }
def grow(x) = x << 1
f = [0]
grow(f)
t { p [7, 8].fetch(*f) }
g = [9]
keep = [g]
keep[0].pop
t { p [7, 8].fetch(*g) }
h = [5]
p h[0]
t { p Hash.new(*h)[:k] }
