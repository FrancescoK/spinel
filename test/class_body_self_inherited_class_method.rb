# In a subclass's body, `self.v = x` and a bare `v` call the inherited
# class methods with self that subclass: a class-level @ivar they touch is
# the subclass's own, as `Sub.v = x` from outside makes it. activesupport's
# number converters each set their own `self.namespace = :delimited` this
# way (through class_attribute).
class Base
  def self.v = @v
  def self.v=(x)
    @v = x
  end
  def self.label = "#{name}:#{v.inspect}"
end

class First < Base
  self.v = 1
end

class Second < Base
  self.v = 2
  p v
  p label
end

class Third < Second
end

p Base.v, First.v, Second.v, Third.v
p First.label, Third.label
