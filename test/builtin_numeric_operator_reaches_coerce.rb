# A number's operator with an operand it does not know hands the call to the
# operand's `coerce`, so `Rational(1, 2) + Meters.new(2)` runs Meters#+. The
# reachability pass leaves a call on a builtin value unmarked, and has to keep
# marking the operators of every numeric kind that coerces: an Integer, a Float,
# a Rational and a Complex. Meters's operators stay emitted and answer as
# CRuby's. (A Complex receiver answers wrongly on master, so it is not here.)
class Meters
  attr_reader :v

  def initialize(v)
    @v = v
  end

  def coerce(other)
    [Meters.new(other), self]
  end

  def +(o) = Meters.new(@v + o.v)
  def -(o) = Meters.new(@v - o.v)
  def *(o) = Meters.new(@v * o.v)
  def /(o) = Meters.new(@v / o.v)
  def **(o) = Meters.new(@v**o.v)

  def to_s = "#{@v}m"
end

m = Meters.new(2)
r = Rational(1, 2)
puts r + m
puts r - m
puts r * m
puts r / m
puts r**m
puts 3 + m
puts 3 - m
puts 1.5 * m
