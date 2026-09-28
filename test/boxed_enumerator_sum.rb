# sum with neither a seed nor a block on an Enumerator read out of a
# container adds its values, as its sum(0) does: Floats compensated.
e = [(1..3).each, 0][0]
p e.sum
p [[1.5, 2.5].each, 0][0].sum
p [[0.1, 0.2, 0.3].each, 0][0].sum
p [[Rational(1, 2), 1].each, 0][0].sum
p [[].each, 0][0].sum
p [e.sum(10), e.sum { |v| v * 2 }]
p [[1, 2**70].each, 0][0].sum
p [Enumerator.new { |y| y << 1; y << 2.5 }, 0][0].sum
p(([["a"].each, 0][0].sum rescue $!.message))
