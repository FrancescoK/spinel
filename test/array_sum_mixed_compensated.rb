# spinel: int64
# Array#sum with no seed is sum(0): CRuby's exact phase, then from the first
# Float the compensated one. A mixed Integer/Float array folded through plain
# `+`, so `[3, 0.1, 0.2].sum` was 3.3000000000000003 where CRuby answers 3.3,
# as did the same array's own `.sum(0)`. A Float seed is left as it was.
p [3, 0.1, 0.2].sum
a = [3, 0.1]
a << 0.2
p a.sum
b = [[3, 0.1, 0.2], 1][0]
p b.sum, b.sum(0)
p [0.1, 0.2, 3, 0.3].sum
p({ a: 3, b: 0.1, c: 0.2 }.values.sum)
p [3, 0.1, 0.2].sum(0), [3, 0.1, 0.2].sum(1r)
p [1, 2, Float::INFINITY, 0.5].sum
p [1, 0.5, Complex(0, 1), 0.25].sum
p [2**70, 0.5, 0.25].sum
p [1, 2, 3].sum, [].sum
