# spinel: int64
# Bignum#upto and #downto without a block answer an Enumerator labeled with
# the receiver and the call, as in CRuby; spinel answered the Array of the
# members.
big = 2**64
p big.downto(big - 2), big.upto(big + 1)
e = big.upto(big + 1)
p e.next, e.size, e.to_a
p big.downto(big - 2).map { |i| i - big }

# An Integer walk toward a Bignum limit goes past the word's end rather than
# stopping there, and one away from it is empty, even from the word's ends.
p 3.upto(2**64).first(2), 3.downto(-2**64).first(2)
p 3.upto(2**64), 3.downto(-2**64)
lo = -9223372036854775807 - 1
hi = 9223372036854775807
neg = [-2**64, 1][0]
pos = [2**64, 1][0]
p lo.upto(neg).to_a, hi.downto(pos).to_a, 3.upto(neg).to_a, 3.downto(pos).to_a
e = lo.downto(neg)
p e.next, e
p 3.upto(pos).take(2), 3.downto(neg).take(2)
