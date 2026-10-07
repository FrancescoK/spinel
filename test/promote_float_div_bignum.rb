# spinel: int64
# Under --int-overflow=promote a Float division's Integer quotient that no
# machine word holds is a Bignum, as Float#floor's already is: the typed
# Float#div and Integer#div(Float) raised RangeError, and the boxed form
# answered a Float. An Integer's div and ceildiv by a Rational floor the
# exact quotient, which promote answers as a Bignum past the word (the
# default build raises RangeError there).
f = 1e20 * (ARGV.size + 1)
k = 7 + ARGV.size
p 1e20.div(1.0)
p f.div(1.0)
p f.div(3)
p (-f).div(7.0)
p 7.div(1e-300) > 10**299
p k.div(1e-300) > 10**299
p k.ceildiv(1e-300) > 10**299
p [f.div(1.0).class, 1e20.div(2.5) + 1]
t = Rational(1, 2**64)
p [7.div(t), 7.ceildiv(t), 7.div([t, 1][ARGV.size]), 7.div(Rational(1, 2**62)), (-7).div(Rational(1, 2**62))]
