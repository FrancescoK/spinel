# spinel: int64
# A Rational is reduced over its numerator's and denominator's magnitudes
# before the sign moves to the numerator: a sum whose cross product passes
# 2**64 keeps all its bits for the gcd, and -2**63 over a negative
# denominator is not negated first.
n = ARGV.size
x = Rational(4611686018427387904 + n, 1)
y = Rational(4611686018427387906, 3)
p x + y
p Rational(-9223372036854775807 - 1 - n, -2)
p Rational(-9223372036854775807 - 1 - n, 2)
p Rational(6 + n, -4)
p Rational(0, -5 - n)
