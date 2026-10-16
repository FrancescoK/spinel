# spinel: int64
# A number on a poly receiver hands a program object back to its ==, so
# `3 == obj` answers `obj == 3`; an object without its own == is not equal.
class Box
  def initialize(v) = @v = v
  def ==(other) = other == @v
end

class Plain
end

def eq(r, a) = r == a
def ne(r, a) = r != a
def int_eq(a) = 3 == a

big = 2**70
p eq(3, Box.new(3)), eq(3, Box.new(4)), ne(3, Box.new(3)), ne(3, Box.new(4))
p eq(2.5, Box.new(2.5)), eq(3.0, Box.new(3)), eq(big, Box.new(big))
p eq(Rational(1, 2), Box.new(Rational(1, 2))), eq(Complex(1, 2), Box.new(Complex(1, 2)))
p int_eq(Box.new(3)), int_eq(Box.new(5)), int_eq(3), int_eq(3.0)
p eq(3, Plain.new), ne(3, Plain.new)

# What does not change: numbers against numbers and other builtins, and
# the object's own == as the receiver.
p eq(3, 3), eq(3, 3.0), eq(3, "3"), eq(3, nil), eq(big, big)
p eq(Box.new(3), 3), eq("a", Box.new("a")), eq(:a, Box.new(:a))
