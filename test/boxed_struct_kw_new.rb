# A Struct or Data class read out of a container is constructed with keyword
# arguments: each keyword names a member, and a keyword that names none, or
# a Data member no keyword names, raises ArgumentError as in CRuby.
S = Struct.new(:a, :b)
K = Struct.new(:a, :b, keyword_init: true)
N = Struct.new(:a, :b, keyword_init: false)
D = Data.define(:x, :y)

def try
  yield
rescue ArgumentError => e
  p [e.class, e.message]
end

s = [S, 0][0]
k = [K, 0][0]
n = [N, 0][0]
d = [D, 0][0]

try { p s.new(a: 1, b: 2) }
try { p s.new(b: "x") }
try { p s.new(a: 1, c: 2) }
try { p k.new(b: 2, a: [1]) }
try { p k.new(c: 2, d: 3) }
try { p n.new(a: 1, b: 2) }
try { p d.new(y: 4, x: 3) }
try { p d.new(x: 3) }
try { p d.new(z: 3) }
try { p d.new(x: 1, y: 2, z: 3) }
try { p d.new(x: 1, y: 2, z: 3, w: 4) }

# the positional form, unchanged
p d.new(3, 4)
p s.new(1, 2)

# the members read back through their own readers
v = d.new(x: "s", y: nil)
p [v.x, v.y, v.class]
w = k.new(a: 10, b: 20)
p w.a + w.b

# an anonymous Data class, as Data.define answers it
d0 = Data.define(:x, :y)
e = [d0, 0][0]
p e.new(x: 3, y: 4)

# one call site, three classes out of a mixed Array
[S, K, D, 0].first(3).each do |c|
  try { p c.new(a: 1, b: 2) }
end
