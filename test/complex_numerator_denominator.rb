# Complex#denominator is the lcm of its parts' denominators and #numerator
# the value times it, in Integer parts; the same through an Array element
[Complex(1, 2), Complex(1.5, 2), Complex(0.1, 0.25), Complex(2.0, 0), Complex(3, 0.5)].each do |c|
  p [c.numerator, c.denominator]
  b = [c, 1][0]
  p [b.numerator, b.denominator]
end
p Complex(1.5, 2).numerator.real.class
p [Complex(1.5, 2).numerator, Complex(1.5, 2).denominator]
p [Complex(0.1, 0.25).numerator, Complex(3, 0.5).denominator]
