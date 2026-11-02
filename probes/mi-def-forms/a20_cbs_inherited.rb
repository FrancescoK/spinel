class Base
  def self.v=(x); @v = x; end
  def self.v = @v
end
class Sub < Base
  self.v = 1
  p v
end
p Base.v, Sub.v
