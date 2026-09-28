# `Array.new(n, <default>)` names the element type, and pushing into the slot
# has to keep it. The push folds its evidence while the pushed value is still
# untyped, so the slot took the boxed array on evidence that had not settled,
# and the `Array.new` seed then unified with THAT rather than the other way
# round -- @f below came out sp_PolyArray while the same array built from a
# bare `[]` came out sp_FloatArray. Only Integer survived, because its element
# evidence settles before the fold.
#
# The re-narrow exists for exactly this and was resetting only the boxed
# SCALAR, never the boxed ARRAY, so the container case it was written for
# never reached it.
class Seeded
  def initialize
    @i = Array.new(0, 0)
    @f = Array.new(0, 0.0)
    @s = Array.new(0, "")
    @bare = []
  end

  # the pushed value is a PARAMETER: its type settles after the push folds,
  # which is what locked the slot
  def add(a, b, c, d)
    @i << a
    @f << b
    @s << c
    @bare << d
    0
  end

  def read
    [@i[0], @f[0], @s[0], @bare[0]]
  end
end

sd = Seeded.new
sd.add(1, 1.5, "ab", 2.5)
p sd.read

# A slot whose pushes genuinely disagree still has to stay boxed: the re-narrow
# re-derives it and it widens again, exactly as a heterogeneous scalar does.
class Mixed
  def initialize
    @m = Array.new(0, 0)
  end
  def add(a, b)
    @m << a
    @m << b
    0
  end
  def read
    [@m[0], @m[1]]
  end
end

mx = Mixed.new
mx.add(1, "two")
p mx.read

# A TABLE is boxed for a reason re-derivation cannot see -- a row handed back
# from another boxed table -- so a slot holding arrays is never reset. This is
# the shape of test/ivar_table_boxed_row_store, kept here beside the rule it
# constrains.
class Rows
  def initialize
    @banks = [[]]
    @patterns = [[]]
  end
  def bank
    @banks[0] = pattern
  end
  def pattern
    row = @patterns[0]
    row << 1
    row << 2
    row
  end
end

p Rows.new.bank
