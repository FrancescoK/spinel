# spinel: int64
# Integer ops with a Bignum on one side: a shift by a Bignum count
# saturates (a right shift leaves 0 or -1, a left shift by a
# huge negative count leaves 0, and zero shifted any distance is 0), and
# Integer#quo by a Bignum is a Rational.
n = 2**65
p 5 >> n
p(-5 >> n)
p 5 << -n
p(-5 << -n)
p 0 << n
p 0 >> -n
p 7.quo(n)
p((-7).quo(n))
p 7.quo(n).class
