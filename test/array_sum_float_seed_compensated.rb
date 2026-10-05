# Array#sum from a Float seed compensates from the first element, as Ruby 4.0.7
# does (4.0.4 ran plain `+` from a Float seed): Integer, Rational and Bignum
# elements join the compensated run, a Complex one ends it uncompensated, and
# the NaN and Infinity arms are CRuby's.
# spinel: int64
p [0.1, 0.2, 0.3].sum(0.0)
p [0.1, 0.2, 0.3].sum(1.5)
p [3, 0.1, 0.2].sum(0.0)
p [0.1, 1r, 0.2].sum(0.0)
p [2**70, 0.1, 0.2].sum(0.0)
a = [[0.1, 0.2, 0.3], 0][0]
p a.sum(0.0)
b = [[0.1, 0.2, 0.3, Complex(0, 1)], 0][0]
p b.sum(0.0)
p [Float::INFINITY, 1.0].sum(0.0), [1.0, 2.0].sum(Float::INFINITY)
p [Float::NAN, 1.0].sum(0.0).nan?
p({ a: 0.1, b: 0.2, c: 0.3 }.values.sum(0.0))
p [0.1, 0.2, 0.3].sum(0.0) { |x| x }
