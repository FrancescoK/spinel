# Integer#[] with a Range on a Bignum reads the Range as an index span: each
# end converts with to_int, so an end written as a Float truncates and keeps
# its exclusivity, as on an Integer that fits a word. big[0...2.5] took the
# walk's inclusive 2 and answered bits 0..2 where CRuby answers 0...2.

big = 2**70 + 0b1111
p big[0..2.5]
p big[0...2.5]
p big[0...3.0]
p big[1..3]
p big[1...3]
def bits(n, r) = n[r]
p bits(big, 0...2.5)
p bits(2**80 + 0b110, 1..2.5)
