# spinel: int64
# Numeric#div by a Float floors the real quotient into an Integer, on every
# receiver: a typed Float, Integer or Rational, a boxed one, and
# Integer#ceildiv, which is -div(-other). A NaN quotient is FloatDomainError
# and a zero divisor ZeroDivisionError. The typed Float and Rational forms
# cast a NaN quotient to an integer (2.5.div(Float::NAN) answered 0, a
# Rational's crashed); the boxed form answered a NaN or wide quotient as a
# Float; a boxed ceildiv divided with `/` (7.ceildiv(2.5) answered 2.8).
f = 2.5 + ARGV.size
x = [f, "a"][0]            # a boxed Float
n = [7, "a"][0]            # a boxed Integer
p [f.div(0.5), x.div(0.5), n.div(2.5), 7.div(2.5), x.div(-0.75), (-f).div(Float::INFINITY)]
p [(f.div(Float::NAN) rescue $!.class), (2.5.div(Float::NAN) rescue $!.class),
   (x.div(Float::NAN) rescue $!.class), (n.div(Float::NAN) rescue $!.class)]
p [(f.div(0.0) rescue $!.class), (x.div(0.0) rescue $!.class),
   (Float::INFINITY.div(2) rescue $!.class), x.div(Float::INFINITY)]
r = Rational(1, 3)
p [r.div(0.1), (r.div(Float::NAN) rescue $!.class), (r.div(0.0) rescue $!.class)]
p [n.ceildiv(2.5), 7.ceildiv(2.5), n.ceildiv(-2.5), n.ceildiv(3)]
p [(n.ceildiv(Float::NAN) rescue $!.class), (7.ceildiv(Float::NAN) rescue $!.class)]
p x.div(1e-300)
