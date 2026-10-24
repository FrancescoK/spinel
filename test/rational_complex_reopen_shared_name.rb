# A method of one name added to Rational and to Complex (and Regexp) keeps
# each class's body; a later def in the same class replaces its own.
class Rational
  def desc = "r#{numerator}"
  def tag(x) = "rt#{x}"
end
class Complex
  def desc = "c#{real}"
  def tag(x) = "ct#{x}"
end
class Regexp
  def desc = "re"
end
class Rational
  def desc = "r2"
end
class Complex
  def wide(a) = "w#{a}"
end
class Complex
  def wide(a, b) = "w#{a}#{b}"
end

p 3r.desc
p Complex(1, 2).desc
p(/a/.desc)
p 3r.tag(1)
p Complex(1, 2).tag(2)
p Complex(1, 2).wide(1, 2)
begin
  1.5.desc
rescue NoMethodError => e
  p e.class
end
