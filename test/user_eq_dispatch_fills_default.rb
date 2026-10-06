# A user == with an optional parameter is reached through the
# synthesized binop and eq dispatch. Each arm passes the default.
class Vector
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def ==(other, precision = 6)
    @x.round(precision) == other.x.round(precision) &&
      @y.round(precision) == other.y.round(precision)
  end
end

a = Vector.new(1.0, 2.0)
b = Vector.new(1.0000001, 2.0)
c = Vector.new(3.0, 4.0)
p a == b
p a != c
p [a, c].include?(b)
p [a, c].index(c)
p a.==(b, 8)
