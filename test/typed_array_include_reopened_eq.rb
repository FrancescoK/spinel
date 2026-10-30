# A program's own Integer#==, Float#== or Rational#== decides what an
# Integer or Float Array finds: the typed include? and index must not
# answer from the general Array's scan, which skips those methods.
class Integer
  def ==(o) = o.is_a?(Rational) ? false : super
end
class Rational
  def ==(o) = false
end
p [1, 2].include?(2r)
p [1, 2].index(2r)
p [1.0, 2.0].include?(2r)
p [1, 2].include?(2)
