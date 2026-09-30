# A Bignum and a Float compare by their exact values, as CRuby's do: every
# Bignum within half an ulp of a Float rounds onto it, so compared as
# doubles they came out equal. Typed and boxed operands, both sides.
x = 2**64 + 1
f = 18446744073709551616.0
p x > f, x >= f, x < f, x <= f, x == f, x <=> f
p f < x, f > x, f <=> x
p (2**100) == (2.0**100), (2**100 + 1) == (2.0**100), (2**70) <=> (2.0**70)
p (2**70 - 1) < (2.0**70), (2**70 + 1) > (2.0**70)
n = -(2**64) - 1
p n < -f, n <=> -f, -f > n
inf = Float::INFINITY
p x < inf, x > -inf, x <=> inf, (x <=> Float::NAN).inspect, x < 1.5e300
p x > 1.5, x == 18446744073709551617.5, x <=> 18446744073709551616.5

b = [x, 1.0][ARGV.size]
g = [f, 1][ARGV.size]
p b > g, b == g, b <=> g, g < b, [b, g].max == b
p 18446744073709551615 <=> f, f <=> 18446744073709551615, [2**64 - 1, f].max, [f, 2**64 + 1].min
