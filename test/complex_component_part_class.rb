# Kernel#Complex(a, b) with a Complex argument follows CRuby's
# nucomp_convert: a Complex with an exact-zero (Integer 0) imaginary part is
# its real part, a Complex a with b an exact zero is a itself, a non-real
# argument gives a + b*i, and two real ones give Complex(a.real, b.real).
# Which part of the answer is a Float follows CRuby's Integer shortcuts.
p Complex(Complex(1, 0.0), 1)
p Complex(Complex(1, 0.0), 1.5)
p Complex(Complex(1, 0), 1.5)
p Complex(Complex(2.0, 0.0), 1)
p Complex(1, Complex(1, 0.0))
p Complex(1, Complex(2.0, 0.0))
p Complex(1.5, Complex(1, 0.0))
p Complex(Complex(1, 0), Complex(2.0, 0.0))
p Complex(Complex(1, 0.0), Complex(1, 0))
p Complex(Complex(1, 2), Complex(0, 0.0))
p Complex(Complex(1, 0.0), Complex(0, 1))
p Complex(Complex(1, 2), 0.0)
p Complex(Complex(1, 2), 3.0)
p Complex(Complex(3, 4), Complex(5, 6))
p Complex(1.5, Complex(2, 3))
p Complex(2, Complex(1.5, 2))
p Complex(Complex(1, 2), Float::INFINITY)
p Complex(Complex(1, 2), Float::NAN)
p Complex(Complex(1, Float::NAN), 1)
p Complex(Complex(1, 0.0))
