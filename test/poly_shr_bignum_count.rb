# `>>=` on a boxed Integer or Bignum by a positive Bignum count leaves only
# the sign (0 or -1), as CRuby answers for any count past the value's width.
# Narrowed to a word, the count kept its low bits: `5 >> 2**64` shifted by 0.
def shifted(v, n)
  x = v
  x >>= n
  x
end
p [shifted(5, 2**64), shifted(-5, 2**64), shifted(5, 2**100), shifted(-5, 2**100)]
p [shifted(2**100, 2**64), shifted(-(2**100), 2**64), shifted(-(2**100), 2**100)]
p shifted(:pad, 1) rescue p $!.class
