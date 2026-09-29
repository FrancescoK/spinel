class B
  def self.r = p(defined?(@@v))
  def self.s = @@v = 1
end
B.r
B.s
B.r

class C
  @@x = "set"
  def self.r = defined?(@@x)
end
p C.r

class D
  def self.r = defined?(@@h) ? @@h : :none
  def self.s(v) = @@h = v
end
p D.r
D.s("a")
p D.r

class E
  def q = defined?(@@o)
  def fill = @@o ||= [1]
end
e = E.new
p e.q
e.fill
p e.q

class F
  def self.q = [defined?(@@a), defined?(@@b)]
  def self.m
    @@a, @@b = 1, "two"
  end
end
p F.q
F.m
p F.q

class G
  def self.w(v)
    x = (@@g = v)
    x
  end
  def self.q = defined?(@@g)
end
p G.q
p G.w(2.5)
p G.q

class H
  @@z = 0
end
p H.class_variable_defined?(:@@z)
p H.class_variable_defined?(:@@nope)
class K
  def self.set = @@k = 1
end
p K.class_variable_defined?(:@@k)
K.set
p K.class_variable_defined?(:@@k)
class P
  @@v = 1
  def self.pr = defined?(@@v)
end
class Q < P
  def self.r = defined?(@@v)
end
p P.pr
p Q.r
module M
  @@mm = 3
  def self.r = defined?(@@mm)
end
p M.r
