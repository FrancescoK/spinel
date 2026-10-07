# `Numeric === x` (and the other builtin class names) when the program
# reopens that class: the reopening adds methods, and the builtin values
# are still its instances -- typed or boxed (date's check_numeric beside
# activesupport's Numeric extensions)
class Numeric
  def kb = self * 1024
end
class String
  def shout = upcase
end
class Integer
  def twice = self * 2
end
def pick(i) = i == 0 ? 29 : (i == 1 ? 1.5 : (i == 2 ? nil : "x"))
def num?(obj) = Numeric === obj
p num?(29), num?(1.5), num?(2**70)
p (0..3).map { |i| Numeric === pick(i) }
p (0..3).map { |i| String === pick(i) }
p (0..3).map { |i| Integer === pick(i) }
p Numeric === 3, String === "s", Integer === 2.5, 3.kb, "a".shout, 4.twice
case pick(0)
when String then p :string
when Numeric then p :numeric
end
