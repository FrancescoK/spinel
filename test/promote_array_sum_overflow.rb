# spinel: int64
# Integer sums promote the whole accumulator when its additions overflow.
p [2**62].sum(2**62)
p [2**62, 2**62].sum(2**62)
p [2**62, 2**62].sum
p [2**62].sum(2**62) { |x| x }
p [2**62, 2**62].sum { |x| x }
p [2**62, 2**62].sum(0.5)
p [2**62, 2**62, -(2**62)].sum
# Boxing a minimum-Integer prefix can allocate before the overflowing step.
p [-(2**62) - 2**62, -1].sum
