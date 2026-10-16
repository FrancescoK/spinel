# dup of an object in a proc body, where the copy is of the
# receiver's class or of a subclass of it: a proc body is written ahead of
# the classes, so each class the copy can allocate is declared to it
class Base
  attr_reader :v
  def initialize(v) = @v = v
  def copy = proc { dup }.call
end
class Sub < Base
  def initialize(v, w) = (super(v); @w = w)
  def w = @w
end
a = Base.new(1).copy
b = Sub.new(2, 3).copy
p a.v, a.class, b.v, b.class, b.w
