# spinel: int64
# A Bignum's divmod, clamp, between? and an Integer's coerce of a Bignum
# hold their operands across the allocations they make, under
# --int-overflow=promote. The divmod's pair is allocated after both
# operands are built, and a fresh one -- the literal divisor's Bignum, a
# computed receiver -- was swept there: under SPINEL_GC_STRESS the division
# read its cleared value as a zero divisor and raised ZeroDivisionError.
q = 2**70 + ARGV.size
n = -(2**70) - ARGV.size
k = 3 + ARGV.size
p (q + 1).divmod(-3)
p q.divmod(k - 6)
p n.divmod(3)
p (q * 2).divmod(q - 5)
p q.divmod(2.5)
p (q + 1).to_s
p (q + 1).to_s(16)
p (q + 1).digits.size
p (q + 1).clamp(q, q + 5)
p (q + 1).clamp(n, q)
p (q - 1).nonzero?
p (q + 1).pow(3, q - 7)
p (q + 1).pow(2)
p [q + 1, q + 2].sum
p (q + 1) == (q + 1)
p (q + 1).coerce(q + 2)
p (q + 1).fdiv(q - 1)
p (q + 1).gcd(q + 3)
p (q + 1).lcm(6)
p (q + 1)[3]
p (q + 1)[0..7]
p (q + 1).bit_length
p (q + 1) <=> (q + 2)
p (q + 1).between?(q, q + 2)
p Integer.sqrt(q + 1)
p (q + 1).to_f
p (q + 1).abs
p (n - 1).abs
p -(q + 1)
p ~(q + 1)
p (q + 1) << 3
p (q + 1) >> 3
p (q + 1) & (q + 7)
p (q + 1) | 6
p (q + 1) ^ (q + 2)
p (q + 1).ceildiv(q - 9)
p (q + 1).remainder(-7)
p (q + 1).modulo(q - 9)
p (q + 1) % 7
p (q + 1).div(-7)
p (q + 1) / (q - 9)
p (q + 1).succ
p (q + 1).pred
p (q + 1).hash == (q + 1).hash
p (q + 1).inspect
p "#{q + 1}"
p [(q + 1), (q + 2)].max
p [(q + 1), (q + 2)].min
p [(q + 2), (q + 1)].sort
p 5.coerce(q + 1)
p [5].first.coerce(q * 3)
p (q + 1).clamp(q - [1].size, q + 9)
p (q + 2).between?(q.pred, q + [7].size)
