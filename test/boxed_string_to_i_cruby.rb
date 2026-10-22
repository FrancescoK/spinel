# String#to_i on a boxed String parses as on a typed one: `_` between
# digits is read, where strtoll stopped at it (#9941). (Past the Integer
# word both raise RangeError, where CRuby answers a Bignum.)
ys = ["1_000", 2]
p ys[0].to_i
zs = [" -12_3x", 3]
p zs[0].to_i
ws = ["abc", 4]
p ws[0].to_i
vs = ["7__8", 5]
p vs[0].to_i
