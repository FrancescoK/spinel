# A splat among the arguments of an inlined yielding method: alone, after
# positionals, before them, empty, too short or too long, into optionals, a
# rest with posts, keywords and a keyword rest, on self and on an object
# receiver, and through an anonymous (*, &) forwarder.

def ints(a, b = 10) = yield(a + b)
def req(a, b) = yield(a * b)
def rp(a, o = 5, *r, z) = yield([a, o, r, z])
def rst(a, *r) = yield(a, r)
def kw(a, b = 5, k: 1) = yield(a + b + k)
def kr(a, b = 1, **o) = yield(a + b, o)
def fwd(*, &) = ints(*, &)

class Deck
  def initialize(n) = @n = n
  def deal(a, b = 1, c = 2) = yield(@n + a + b + c)
  def pass(*, &) = deal(*, &)
end

def try
  yield
rescue ArgumentError => e
  puts e.message
end

ints(*[1, 2]) { |v| puts v }
ints(*[1]) { |v| puts v }
nums = [3]
ints(4, *nums) { |v| puts v }
ints(*nums, 6) { |v| puts v }
ints(1, *[]) { |v| puts v }
req(*[3, 4]) { |v| puts v }
fwd(7, 8) { |v| puts v }
fwd(7) { |v| puts v }

rp(*[1, 2]) { |v| p v }
rp(*[1, 2, 3]) { |v| p v }
rp(*[1, 2, 3, 4, 5]) { |v| p v }
rp(1, *[2, 3, 4], 9) { |v| p v }
rst(*[1, 2, 3]) { |a, r| p [a, r] }
kw(*[1, 2], k: 10) { |v| puts v }
kw(1, *[], k: 2) { |v| puts v }
kw(*[1]) { |v| puts v }
kr(*[1, 2]) { |x, o| p [x, o] }
h = { z: 4 }
kr(*[5], y: 1, **h) { |x, o| p [x, o] }

d = Deck.new(100)
d.deal(*[1]) { |v| puts v }
d.deal(*[1, 2, 3]) { |v| puts v }
d.deal(1, *[10]) { |v| puts v }
d.pass(1, 2) { |v| puts v }

v = ints(*[1, 2]) { |x| x * 2 }
puts v
puts "got #{ints(*[4]) { |x| x + 1 }}"
[[1, 2], [3]].each do |pair|
  ints(*pair) { |x| puts x }
end
ints(*[1]) do |x|
  ints(*[x, x]) { |y| puts y }
end

try { ints(*[1, 2, 3]) { |v| puts v } }
try { ints(*[]) { |v| puts v } }
try { rp(*[1]) { |v| p v } }
try { d.deal(*[]) { |v| puts v } }
try { d.pass(1, 2, 3, 4) { |v| puts v } }
try { fwd(1, 2, 3) { |v| puts v } }
try { kr(*[1, 2, 3]) { |x, o| p x } }
