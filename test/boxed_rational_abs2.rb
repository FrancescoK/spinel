# abs2 on a Rational read out of a container answers its square as a
# Rational, as a typed Rational does; a Bignum Rational too, which raised
# even in a plain local.
r = [Rational(7, 3), 0][0]
p r.abs2
q = [Rational(-5, 2), 0][0]
p q.abs2
b = [Rational(2**70, 3), 0][0]
p b.abs2
p Rational(-(2**70), 3).abs2
p [2, 2.5, -3].map { |v| [v, Rational(1, 2)][0].abs2 }
s = ["x", Rational(1, 2)][0]
e = (s.abs2 rescue $!)
p e.message
