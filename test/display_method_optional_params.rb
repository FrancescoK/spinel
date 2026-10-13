# inspect / to_s whose parameters are all optional: the String p, puts and
# an inspected Array ask for is the method's own, called with its defaults

class N
  def initialize(x) = @x = x
  def inspect(indent = 0) = "N(#{@x},#{indent})"
end

class T
  def initialize(x) = @x = x
  def to_s(fmt = "T") = "#{fmt}(#{@x})"
end

# a default that reads the receiver
class L
  def initialize(level) = @level = level
  def inspect(indent = @level, *rest, mark: "+") = "#{mark * indent}L"
end

module Shown
  def inspect(depth = 1) = "#{self.class.name}/#{depth}"
end

class M
  include Shown
end

class Base
  def to_s(sep = ":") = "base#{sep}"
end

class Sub < Base
end

p N.new(1)
p [N.new(2)]
puts N.new(3).inspect
puts N.new(3).inspect(5)
puts T.new(4)
puts "#{T.new(5)}"
puts T.new(6).to_s("U")
p L.new(3)
puts L.new(2).inspect(1, mark: "-")
p M.new
puts Sub.new

# through a value that may be one of several classes
[N.new(7), L.new(1), M.new, :sym].each { |v| p v }
[T.new(8), Sub.new, :sym].each { |v| puts v }
