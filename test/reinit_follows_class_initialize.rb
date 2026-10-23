# A method that calls initialize runs the initialize the receiver's class
# has: a later reopening's, a subclass's own, or an included module's.
class Base
  attr_reader :v
  def initialize(x) = @v = x
  def reload(x) = initialize(x)
end
class Base
  def initialize(x) = @v = -x
end
class Sub < Base
  def initialize(x) = @v = x * 100
end
module Init
  def initialize(x) = @v = x + 1000
end
class Mixed < Base
  include Init
end
b = Base.new(1)
p b.reload(2), b.v
s = Sub.new(1)
s.reload(2)
p s.v
m = Mixed.new(1)
m.reload(2)
p m.v
