# spinel: int64
# A counted Integer loop whose last value is 2**63-1 stops there: the
# counter must not step past the limit (signed overflow) and wrap round to
# a value that is within it again. Each loop breaks after 5 rounds, so a
# regression prints 5 instead of hanging.
n = ARGV.size
x = 9223372036854775807 - n

c = 0
(x - 2).upto(x) { |v| c += 1; break if c == 5 }
p c

c = 0
(x - 2).upto(x) { |v| c += 1; next if v.odd?; break if c == 5 }
p c

c = 0
(x - 4).step(x, 2) { |v| c += 1; break if c == 5 }
p c

c = 0
(x - 3).step(x, 2) { |v| c += 1; break if c == 5 }
p c

p (x - 4).step(x, 2).to_a.map { |v| v - x }
p (x - 3).step(x, 2).to_a.map { |v| v - x }
p (x - 1).step(x).to_a.size

y = -x
c = 0
(y + 2).downto(y) { |v| c += 1; break if c == 5 }
p c
p (y + 3).step(y, -2).to_a.map { |v| v - y }
