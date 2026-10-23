# A method calls initialize, and a subclass whose initialize calls super
# never runs that method: the call is not refused.
class Base
  attr_reader :v
  def initialize(x) = @v = x
  def reset = initialize(0)
end
class Sub < Base
  def initialize(x)
    super(x * 10)
  end
end
b = Base.new(1); b.reset; p b.v
p Sub.new(2).v
