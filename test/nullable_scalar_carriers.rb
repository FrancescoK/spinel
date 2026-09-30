# A nil reaching an Integer or a Float slot (the sentinel a missed read
# leaves, or a literal nil) is nil to every later read, whichever carrier it
# went through: the last statement of a parenthesized sequence, a class
# variable, an attr_reader or its alias, an attr_writer, and a Struct member
# set by its constructor (from a nil, or left out) or by its setter.

def t
  yield
rescue => e
  puts "#{e.class}: #{e.message}"
end

x = 1
p x
x = (sq = [1]; _, y = *sq; y)
p [x, x.nil?, x.is_a?(Integer), [1, x].compact]
t { p [1, x].sum }
t { p [1, x].sort }
t { p Integer(x) }
z = (w = [1.5][ARGV.size + 1]; w)
z ||= 7.5
p z

class K
  @@c = 3
  def self.a = (@@x = 1)
  def self.b = (@@x = nil)
  def self.x = @@x
  def self.f(v) = (@@f = v)
  def self.g = @@f
  def self.c = @@c
  def self.cn = (@@c = [3][ARGV.size + 1])
end
K.a
p K.x
K.b
p [K.x, [*K.x], K.x.to_a]
t { p K.x > 0 }
t { p [1, K.x].sum }
K.f(1.5)
K.f([1.5][ARGV.size + 1])
p [K.g, K.g.nil?]
K.cn
p [K.c, [K.c].compact]

class A
  attr_reader :x
  alias y x
  attr_accessor :w
  def initialize(x) = (@x = x)
end
p A.new(1).x
a = A.new(nil)
p [a.x, a.y]
t { p a.x > 0 }
t { p a.y > 0 }
t { p [1, a.x].minmax }
p [1, a.x].delete_if(&:nil?)
a.w = 2
a.w = nil if ARGV.empty?
p [a.w, a.w.nil?]
t { p a.w + 1 }

S = Struct.new(:m, :n)
p S.new(1, 2).m <=> 1
s = S.new(nil, 2)
p [s.m <=> 1, s.m.nil?]
t { p s.m > 0 }
u = S.new(3)
p [u.n, u.n.nil?]
t { p u.n * 2 }
v = S.new(4, 5)
v.n = nil if ARGV.empty?
p [v.n, [v.n].compact]

class P < Struct.new(:m, :n)
  def sum = m + n
end
o = P.new(nil, 2)
t { p o.m > 0 }
t { p o.sum }
