# defined?(super) answers "super" when the method has a super to call: an
# ancestor's method, the next one in an include or prepend chain, Class#new,
# or one every object has. It answered nil always.

class A
  def to_s = defined?(super).inspect
  def initialize = (@d = defined?(super))
  attr_reader :d
  def nope = defined?(super)
  def in_block = [1].map { defined?(super) }
  def self.new(*) = (p(defined?(super)); super)
  def self.zzz = defined?(super)
end
a = A.new
p a.to_s, a.d, a.nope, a.in_block, A.zzz

class S
  def baz = :s
  def self.cm = :cs
end
class T < S
  def baz = [defined?(super), super]
  def self.cm = defined?(super)
  def self.cn = defined?(super)
end
p T.new.baz, T.cm, T.cn

# an included module's method, over the superclass's
module I1
  def baz = [:i1, defined?(super)]
end
class U < S
  include I1
end
p U.new.baz

# a prepended module's method, over the class's own, and over none
module M1
  def foo = defined?(super) ? [:m1, *super] : [:m1]
end
class P
  def foo = [:p]
  prepend M1
end
class R
  prepend M1
end
p P.new.foo, R.new.foo

# chains: include, then a subclass's prepend
module Base1
  def hi = :base1
end
class B
  include Base1
  def hi = [:b, defined?(super) && super]
end
module Pre
  def hi = [:pre, defined?(super) && super]
end
class C < B
  prepend Pre
  def hi = [:c, defined?(super) && super]
end
p B.new.hi, C.new.hi

# an ancestor that undefs the name hides the method above it
class W1
  def test = :w1
end
class W2 < W1
  undef :test
end
class W3 < W2
  def test = defined?(super)
end
p W3.new.test
