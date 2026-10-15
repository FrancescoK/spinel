# spinel: int64
# Bignum#upto and #downto without a block answer an Enumerator labeled with
# the receiver and the call, as in CRuby; spinel answered the Array of the
# members.
big = 2**64
p big.downto(big - 2), big.upto(big + 1)
e = big.upto(big + 1)
p e.next, e.size, e.to_a
p big.downto(big - 2).map { |i| i - big }
