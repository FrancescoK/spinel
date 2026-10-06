# spinel: int64
# Integer#size answers sizeof(long) (8) for a value a Fixnum holds and the
# byte count of a Bignum's magnitude otherwise, which is never less. A
# Bignum slot answered ceil(bit_length / 8): 1 for a small value it holds
# (2**70 - (2**70 - 7)), 0 for zero, and 8 for -(2**64), whose
# two's-complement bit_length is a bit short of its magnitude's. The probes
# read typed Bignum slots and boxed ones.

b = 2**70
p (b - (b - 7)).size, (b - b).size, (b * -1 + b - 3).size, (-(2**64)).size
p (-(2**128)).size, (2**64).size, (2**63).size, (-(2**63)).size, (2**100).size
p b.size, (-b).size, (2**200).size, 7.size
a = [2**64, 1, b - (b - 7), -(2**64), b - b, -(2**128)]
p a[0].size, a[1].size, a[2].size, a[3].size, a[4].size, a[5].size
