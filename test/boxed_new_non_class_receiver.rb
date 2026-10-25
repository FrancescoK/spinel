# spinel: gc-stress
# `.new` on a boxed receiver that holds anything but a Class (an Integer,
# a Symbol, nil, a Float, a user object) raises NoMethodError, with keyword,
# positional, splat or no arguments, where a user class's constructor was taken.
class P
  def initialize(a: 1, b: 2) = (@a = a; @b = b)
  attr_reader :a, :b
end
class Q
  def initialize(a, b) = (@a = a; @b = b)
  attr_reader :a, :b
end
class Z
  def initialize = (@z = 1)
end
S = Struct.new(:a, :b)
D = Data.define(:a, :b)

def t
  yield
rescue => e
  p [e.class, e.message]
end

pc = [P, 0][0]
o = pc.new(a: 5)
p [o.a, o.b]
[P, S, D, 0, 1, 2, 3, 4, 5, nil, :s].each { |c| t { o = c.new(a: 1, b: 2); p [o.class, o.a, o.b] } }
[Q, S, 0, 1, 2, 3, 4, nil].each { |c| t { o = c.new(1, (puts "arg"; 2)); p [o.class, o.a, o.b] } }
[S, P, 0, 1, 2, 3, nil].each { |c| t { p c.new(*[]).class } }
[Z, P, 0, 1, 2, 3, nil, :s].each { |c| t { p c.new.class } }
[P, P.new, Q.new(1, 2), 1.5].each { |c| t { p c.new(a: 1).class } }
[Q, P.new, 1.5].each { |c| t { p c.new(1, 2).class } }
