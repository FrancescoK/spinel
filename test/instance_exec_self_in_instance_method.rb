# self inside an instance_exec / instance_eval block, or a proc handed to
# instance_exec, in an instance method of another class is the receiver:
# its class, its methods and its ivars, also for a boxed receiver.
class A
  def initialize = (@v = 5)
  def m = "A"
end
class B
  def initialize = (@v = "b")
  def m = "B"
  def a(o) = o.instance_exec { [self.class, m, @v] }
  def b(o) = o.instance_eval { self }
  def c(o) = o.instance_exec(3) { |n| [self.class.name, n, [1].map { self.class }] }
  def d(o) = o.instance_exec { self.m + "!" }
  def e(o) = (pr = proc { [self.class.to_s, m] }; o.instance_exec(&pr))
  def f(o) = [self.class, o.instance_exec { self.class }, self.class, @v]
  def g(o) = o.instance_eval { self.equal?(o) }
end
b = B.new
a = A.new
p b.a(a)
p b.b(a).class
p b.c(a)
p b.d(a)
p b.e(a)
p b.f(a)
p b.g(a)
x = [A.new, B.new][rand < 2 ? 0 : 1]
p b.a(x)
y = [A.new, B.new][rand < 2 ? 1 : 0]
p b.a(y)
p B.new.a(A.new).length
