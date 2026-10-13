# a method of the class calling its own initialize: it runs the body again
# and answers the body's value, as CRuby's initialize does

class P
  def initialize(s) = (@s = s)
  def reload(s) = initialize(s)
end
p P.new(1).reload(2)

class Q
  attr_reader :a, :b
  def initialize(a, b = 10, c: 0)
    @a = a
    @b = b + c
  end
  def reset(x)
    initialize(x, c: 1)
    self
  end
end
q = Q.new(1)
p [q.a, q.b]
q.reset(7)
p [q.a, q.b]

class R
  def initialize(s) = (@s = s)
  def reload(s)
    initialize(s)
    self
  end
  def s = @s
end
p R.new(1).reload(3).s

# the copy is no method of the class's to see
p P.instance_methods(false)
p P.private_instance_methods(false).sort
p P.new(1).respond_to?(:reload)
