# spinel: reject-subclass: whose class's initialize uses super, yield or block_given?
# A method that calls initialize on an object of a subclass whose
# initialize calls super: that initialize has no copy as a plain method,
# so the call is refused.
class Base
  attr_reader :v
  def initialize(x) = @v = x
  def reload(x) = initialize(x)
end
class Sub < Base
  def initialize(x)
    super(x * 10)
  end
end
s = Sub.new(1)
s.reload(2)
p s.v
