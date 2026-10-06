# spinel: int64
# An Integer past 2^53 against a Float compares exactly, as CRuby does: the
# Integer is not rounded to a double first (#7505).
a = 9007199254740993      # 2**53 + 1
f = 9007199254740992.0    # 2**53
p a == f, a != f, a > f, a >= f, a < f, a <= f, a <=> f
p f == a, f != a, f < a, f <= a, f > a, f >= a, f <=> a
n = -a
m = -f
p n == m, n < m, n <=> m, m > n
p a == 9007199254740992.0, a > 9007199254740992.0
p 9007199254740993 == f, 9007199254740993 <=> f

# the edges of the 64-bit range against a Float that rounds past them
big = 9223372036854775807
p big < 9223372036854775808.0, big <=> 9223372036854775808.0
low = -9223372036854775807 - 1
p low == -9223372036854775808.0, low <=> -9223372036854775808.0

# a NaN compares with nothing
nan = 0.0 / 0.0
p a == nan, a != nan, a < nan, a >= nan, a <=> nan

# small values keep their answers
p 3 == 3.0, 3 < 3.5, 4 > 3.5, 3 <=> 3.0, 2.5 <=> 3

# Ranges built on the comparison
p (a..a) == (f..f), (f..f) == (a..a), (a..a).overlap?(f..f)
p (1..3) == (1.0..3.0), (1...3) == (1.0..3.0), (1..) == (1.0..)

# boxed operands
b = [a, :x][0]
g = [f, :x][0]
p b == g, b != g, b > g, b < g, b <=> g, g <=> b

# a slot that may hold nil
def pick(x, c) = c ? x : nil
v = pick(a, true)
p v > f, v <=> f
