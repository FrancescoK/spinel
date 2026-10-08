# `alias inspect m` / `alias_method :to_s, :m`: p, puts, interpolation and
# a containing object's own inspect call the aliased method, which nothing
# else names (activesupport's Date: `alias_method :default_inspect, :inspect`
# then `alias_method :inspect, :readable_inspect`)
class D
  def initialize(n) = @n = n
  def readable_inspect = "D(#{@n})"
  alias_method :default_inspect, :inspect
  alias_method :inspect, :readable_inspect
end
class Label
  def initialize(s) = @s = s
  def render = "<#{@s}>"
  alias to_s render
end
class Sub < D; end
class Box
  def initialize(d) = @d = d
end
p D.new(1)
p [D.new(2)]
puts D.new(3).inspect
p Sub.new(4)
l = Label.new("x")
puts l
puts "label #{l}"
p Box.new(D.new(5)).inspect.sub(/0x\h+/, "X")
