class Base
  def self.v=(x); @v = x; end
  def self.v = @v
end
class Sub < Base
  [1].each { |i| self.v = i + 10 }
  tap { p v }
end
p Base.v, Sub.v
