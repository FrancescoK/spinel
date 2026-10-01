# In a `class Numeric` reopening, self is whichever number the method was
# called on -- an Integer, a Float -- as activesupport's Numeric extensions
# (bytes, kilobytes, ...) are: it is held boxed and the arithmetic on it
# dispatches on the value, as in an Object or Array reopening.
class Numeric
  def kilo = self * 1000
  def half_up = (self + 1) / 2
  def describe = "#{self.class}:#{self}"
end

p 2.kilo, 1.5.kilo, 7.half_up, 2.5.half_up
p 3.describe, 0.25.describe
