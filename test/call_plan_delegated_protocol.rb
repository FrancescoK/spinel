# Protocol calls retain their user target and its precedence over a fallback.
class Ordered
  include Comparable
  def <=>(other) = 0
end
class Equal
  def ==(other) = false
end
class Both
  include Comparable
  def ==(other) = false
  def <=>(other) = 0
end
a = Ordered.new
b = Ordered.new
p a == b, a != b, a < b, a <= b, a > b, a >= b, a === b
x = Equal.new
p x != Equal.new, x === Equal.new
z = Both.new
p z == Both.new, z != Both.new, z === Both.new
