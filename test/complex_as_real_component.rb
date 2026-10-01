# A Complex where a real is expected. Kernel#Complex(a, b) is a + b*i, so a
# Complex component combines (a Float part of b makes both parts Float);
# Complex.rectangular and .polar take a Complex with a zero imaginary part as
# its real part and raise TypeError "not a real" otherwise; Rational(c) is
# c.to_r; Float#fdiv(c) is self / c. Each gave invalid C. Complex#to_f and
# #to_r name the value in their RangeError, and #to_f refuses a 0.0 part.

def t
  p yield
rescue => e
  p [e.class, e.message]
end

t { Complex(Complex(3, 4), Complex(5, 6)) }
t { Complex(1, Complex(5, 6)) }
t { Complex(Complex(3, 4), 2) }
t { Complex(Complex(3, 4)) }
t { Complex(Complex(1.5, 2), 0.5) }
t { Complex(Complex(1, 2), Complex(5.0, 6)) }
t { Complex(Complex(1, 2), 3.0) }
t { Complex(Complex(1, 2), 0.0) }
t { Complex(1.5, Complex(1, 2)) }
t { Complex(Complex(1, 0), 0) }

t { Complex.rectangular(1, 2i) }
t { Complex.rectangular(2i) }
t { Complex.rect(1, Complex(2)) }
t { Complex.rectangular(1.0 + 0i, 2 + 0.0i) }
t { Complex.rectangular(1.0 + 0i, 2 + 0.0i).imag }
t { Complex.polar(1, 2i) }
t { Complex.polar(2i) }
t { Complex.polar(Complex(2), 0) }

t { Rational(Complex(1, 0)) }
t { Rational(Complex(1, 2)) }
t { Rational(Complex(1.5, 0)) }
t { Rational(Complex(2.5, 0.0)) }
t { Rational(Complex(3, 0), 2) }
t { Rational(1, Complex(2, 0)) }
t { Rational(Complex(1, 0), Complex(2)) }
t { x = [Complex(1, 2), 1][0]; Rational(x) }
t { x = [Complex(3, 0), 1][0]; Rational(x) }

t { 74620.09.fdiv(Complex(8, 2)) }
t { 1.5.fdiv(Complex(2)) }
t { x = 2.0; x.fdiv(Complex(1, 1)) }

t { Complex(1, 2).to_f }
t { Complex(1, 0.0).to_f }
t { Complex(1.5, 0).to_f }
t { Complex(1, 2).to_r }
t { Complex(1, 0.0).to_r }
