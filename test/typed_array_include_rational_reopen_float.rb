# A program's own Rational#== decides only what a Rational needle finds:
# a Float or Integer needle in a typed Array is still found by value.
class Rational
  def ==(o) = false
end
def gi(a, x) = a.include?(x)
def gf(a, x) = a.include?(x)
def hi(a, x) = a.index(x)
p gi([1, 2], 2.0), gi([1, 2], 3), gi([1, 2], 2r)
p gf([1.0, 2.0], 2), gf([1.0, 2.0], 2.5), gf([1.0, 2.0], 2r)
p hi([1, 2], 2.0), hi([1, 2], "x"), hi([1, 2], 2r)
p [1, 2].include?(2r)
