class B
  def m = 1
  alias a1 m
  alias a2 m
  def a1 = 9
  def m = 2
end
b = B.new
p b.a1, b.a2, b.m

class C
  def m = 1
  alias a1 m
  alias a2 a1
  def a1 = 9
  def m = 2
end
c = C.new
p c.a1, c.a2, c.m

class D
  def m = 1
  alias a1 m
  def a1 = 9
end
p D.new.a1, D.new.m

class E
  def m = 1
  alias a1 m
  alias_method :a2, :m
  alias a3 a2
  def a1 = 7
  def a2 = 8
  def m = 2
  def via = [a1, a2, a3, m]
end
p E.new.via

class F
  def m(x) = x + 1
  alias a1 m
  alias a2 m
  def a1(x) = x * 100
  def m(x) = x - 1
end
f = F.new
p f.a1(5), f.a2(5), f.m(5)
p F.instance_methods(false).sort

class Y
  def each_twice = [yield(1), yield(2)]
  alias e1 each_twice
  alias e2 each_twice
  def e1 = :redone
  def each_twice = :gone
end
y = Y.new
p y.e1, y.e2 { |v| v * 10 }, y.each_twice

module Mx
  def m = 1
  alias a1 m
  alias a2 m
  def a1 = 9
  def m = 2
end
class Kx
  include Mx
end
kx = Kx.new
p kx.a1, kx.a2, kx.m
p Kx.new.respond_to?(:a2), B.instance_methods(false).sort
