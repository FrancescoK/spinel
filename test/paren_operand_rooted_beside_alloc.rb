# spinel: gc-stress
# A parenthesized operand is bound in order like a call's: left to C, the
# value `([21] * 17)` built was held by nothing once its own expression
# ended, and building the next operand collected it, so `+` read a freed
# array (a TypeError or garbage, depending on when the collector ran).
module Images
  SECTORS = ([21] * 17) + ([19] * 7) + ([18] * 6) + ([17] * 5)
end

def table(n) = ([1] * n) + ([2] * n)
def literal(n) = [n, n + 1] + ([2] * n)
def block_value(n) = begin; [1] * n; end + ([2] * n)
def two_statements(n) = (x = n; [x] * n) + ([3] * n)
def ordered(r) = (r.shift) - (r.shift)

p Images::SECTORS.length, Images::SECTORS.sum
p table(3), literal(3), block_value(2), two_statements(2)
p ordered([10, 3])
