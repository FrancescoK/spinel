# A Kernel reopening's method called bare from another class's method runs
# with that instance as self, private or not, and hands a block on through
# another of the reopening's methods.
module Kernel
  def foo = "foo#{self.class}"
  private :foo
  def bar = "bar"
  def k1 = yield
  def k3(&b) = k1(&b)
  def k4
    yield
  ensure
    nil
  end
  def k5(&b) = k4(&b)
end
p bar
p 5.bar
p foo
begin; p 5.foo; rescue NoMethodError => e; p e.class; end
class K; def t = foo; end
p K.new.t
class S2
  def a = k1 { 1 }
  def c = k3 { 3 }
  def d = k4 { 4 }
  def e = k5 { 5 }
end
s = S2.new
p s.a, s.c, s.d, s.e
