# A respond_to? with a name known only at run time, on self or receiverless in
# a base class's method, answers false for a method a subclass undefines.
class A
  def probe(n) = self.respond_to?(n)
  def bare(n) = respond_to?(n)
  def x = 1
  def y = 2
end
class C < A
  undef_method :x
end
class D < C
  def x = 3
end
[A.new, C.new, D.new].each do |o|
  p [o.class, o.probe(:x), o.bare("x"), o.probe(:y), o.respond_to?(:x)]
end
