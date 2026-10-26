# spinel: rbs-seed-run
# An empty {} passed as a keyword argument to a method whose signature
# types it untyped is the hash the method fills, as without a signature
# and as a positional one is.
class KwEmptyHashFill
  def fill(into: nil)
    into[:name] = "ari" if into
    into
  end

  def outer(**kw) = inner(**kw)
  def inner(into: nil) = (into[:v] = 1)
end

a = {}
KwEmptyHashFill.new.fill(into: a)
p a
b = {}
KwEmptyHashFill.new.outer(into: b)
p b
