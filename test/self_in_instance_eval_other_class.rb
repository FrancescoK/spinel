# `self` written in an instance_eval/instance_exec block inside an instance
# method of another class is the block's receiver, not the method's own
# object. It was typed as the method's class: a method answering it assigned a
# `sp_D *` into a `sp_C *` slot (the C did not build), or answered the wrong
# object.
class D
  def initialize(n) = @n = n
  def n = @n
end

class C
  def initialize(o) = @o = o

  def a = @o.instance_eval { self }

  def b
    x = @o.instance_eval { self }
    x
  end

  def c = (@o.instance_eval { return self if @n > 0 }; 1)

  def d = @o.instance_exec(10) { |k| [self.n + k, self.class] }

  def e = [self.class, @o.instance_eval { self.class }, self.class]
end

c = C.new(D.new(1))
p c.a.class, c.a.equal?(c.a), c.b.n
p c.c.class, C.new(D.new(0)).c
p c.d, c.e
