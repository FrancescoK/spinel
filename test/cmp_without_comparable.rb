# A class that defines <=> without including Comparable answers == as
# Object does (identity), and has no <, <=, >, >=, between? or clamp:
# those are Comparable's. A class that includes it answers all of them.

class K
  attr_reader :v
  def initialize(v) = @v = v
  def <=>(o) = v <=> o.v
end

class C
  include Comparable
  attr_reader :v
  def initialize(v) = @v = v
  def <=>(o) = v <=> o.v
end

class D < C
end

def try
  yield
rescue NoMethodError => e
  puts e.message
end

a = K.new(1)
b = K.new(1)
p a == b
p a != b
p a == a
p [a].include?(b)
p [K.new(2), K.new(1)].sort.map(&:v)
p [K.new(2), K.new(1)].max.v
try { p a < b }
try { p a <= b }
try { p a > b }
try { p a >= b }
try { p a.between?(b, b) }
try { p a.clamp(b, b).v }

c1 = C.new(1)
c2 = C.new(1)
p c1 == c2
p c1 != c2
p c1 < c2
p c1 >= c2
p c1.between?(c2, c2)
p c1.clamp(c2, c2).v
p D.new(1) == D.new(1)
p D.new(1) < D.new(2)

xs = [a, 1]
x = xs[0]
p x == b
ys = [c1, 1]
y = ys[0]
p y == c2
p y <= c2
