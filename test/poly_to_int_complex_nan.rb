# to_int / to_i called on a boxed number answers what the typed call does:
# a Complex its real part only with an exact-zero imaginary part (else
# RangeError), and NaN or an infinity FloatDomainError.
def f(x) = x.to_int
def g(x) = x.to_i
def t(&b) = (b.call rescue "#{$!.class}: #{$!.message}")
p f(3.9), f(Rational(7, 2)), f(Complex(3, 0)), f(7), f(-2.5)
p g(3.9), g(Complex(4, 0)), g("12"), g(nil)
p t { f(Complex(3, 1)) }
p t { f(Complex(3, 0.0)) }
p t { f(Float::NAN) }
p t { g(Float::INFINITY) }
p t { g(-Float::INFINITY) }
p((Float::NAN.to_i rescue $!.message))
p((Float::INFINITY.to_i rescue $!.message))
p(((-Float::INFINITY).to_int rescue $!.message))
x = 0.0 / 0
p((x.to_i rescue $!.message))
