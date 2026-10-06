# spinel: int64
# Under --int-overflow=promote a Float division's Integer quotient that no
# machine word holds is a Bignum, as Float#floor's already is: the typed
# Float#div and Integer#div(Float) raised RangeError, and the boxed form
# answered a Float.
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
