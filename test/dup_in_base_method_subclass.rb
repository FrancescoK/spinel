# `dup` or `clone` of self in a base class's method, run for a subclass's
# instance, copies the whole subclass instance: its own instance variables
# come along, and the copy answers the subclass's methods.
class Base
  def initialize(e) = @e = e
  def with(&b)
    c = dup
    b.call(c)
    c
  end
  def twin = clone
end

class Var < Base
  def initialize(e, n, op = nil)
    @n = n
    @op = op
    super(e)
  end
  def with_op(o) = with { |m| m.update_op(o) }
  def update_op(o) = @op = o
  def show = [@e, @n, @op]
end

v = Var.new("e", "n").with_op("op")
p v.show, v.class
w = Var.new("a", "b", "c").freeze
t = w.twin
p t.show, t.frozen?, t.equal?(w)
b = Base.new("x").with { |m| m }
p b.class
