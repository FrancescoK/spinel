# spinel: int64
# Integer#&, #| and #^ on a boxed Integer and a Bignum keep the Bignum's
# width. sp_poly_band, sp_poly_bor and sp_poly_bxor read both sides as
# int64, so a `|` or `^` line below answered 28 (or 29) where CRuby answers
# a Bignum. A fold by a Symbol, an element's OP= and a receiver of an
# unknown kind reach them. A `&` that masks a Bignum fits an int, and stays
# as it was.
big = 2**64

pa = [28, big, "x"]
pa.pop
p pa.reduce(:|)
p pa.reduce(:^)
p [big, 28, :s].first(2).inject(:|)
p [big + 4, 4, :s].first(2).reduce(:&)

ops = [:|, :+]
op = ops[ARGV.size]
p pa.reduce(op)

a = [28, "s"]
a[0] |= big
p a[0]

h = {n: 28, s: "t"}
h[:n] |= big
p h[:n]
h[:n] ^= 1
p h[:n]

r = ARGV.size == 0 ? [28] : {0 => 28}
r[0] |= big
p r[0]

# a pair of machine words, and an operand that is not an Integer, as before
p [28, 3, :s].first(2).reduce(:|)
begin
  p [big, 1.5, :s].first(2).reduce(:|)
rescue TypeError => e
  p e.message
end
