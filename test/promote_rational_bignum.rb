# Under --int-overflow=promote a Rational whose terms leave the machine word
# goes on as a big Rational, as an Integer goes on as a Bignum: arithmetic,
# powers, numerator and denominator, the exact Float#to_r, Float#rationalize,
# Kernel#Rational(String) and a big Rational's round; a result that fits is
# the small Rational again.
p Rational(2**70, 3)
p Rational(2**70, 3) + Rational(1, 7)
p Rational(2**70, 3).numerator
p (Rational(1, 3) ** 50).denominator
a = Rational(2**40, 3)
b = Rational(2**40, 5)
p a * b, (a * b).class, (a * b) / (a * b), ((a * b) / (a * b)) == 1
p Rational(1, 2**40) + Rational(1, 3**30)
p Rational(1, 2**40) - Rational(1, 3**30)
p (a * b) > a, (a * b).to_f
p 1e-30.to_r.denominator > 2**64, 1e300.to_r.to_i > 0
p 1e-30.rationalize(Rational(1, 10**40)), 1e-30.rationalize
p 0.1.rationalize, 0.1.rationalize(Rational(1, 100)), -2.5.rationalize(0.1)
p Rational("1/12345678901234567890123"), Rational("0.1234567890123456789012")
p 0.1r ** 30, (2**80).to_r
p (1e-30.to_r * 10**30).round(5)
x = [Rational(1, 2**40), 1][0]
p x * x
r = Rational(1, 3)
s = r
40.times { s *= r }
p s.denominator == 3**41
