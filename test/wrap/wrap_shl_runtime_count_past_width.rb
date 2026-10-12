# spinel: not-cruby -- --int-overflow=wrap: a left shift by a run-time count
# of 64 or more moves every bit out of the word, so the wrapped value is 0,
# as a literal count of 64 gives; CRuby answers a Bignum. A negative count
# still shifts right.
n = ARGV.size
x = 1 + n
c = 64 + n
p x << 64
p x << c
p x << (c + 1)
p x << (c + 100)
p((x << c) - 1)
p(-x << c)
p 0 << c
p x << (63 + n)
p x << -(c)
p(-x << -(c))
m = Array.new(66) { |i| (1 << i) - 1 }
p m[62], m[63], m[64], m[65]
