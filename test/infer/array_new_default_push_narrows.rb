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

# A second ivar written the first (`@alias_i = @seed_i`) is the same Array,
# and the alias propagation widens both names together when a push through
# one of them is of another kind. A push of the slot's own kind, of a
# parameter that settles late, leaves the pair typed: the slot is boxed for
# a round or two while the parameter settles, and the re-narrow resets it.
# Only a slot the alias step itself widened is kept from the re-narrow.
class Aliased
  def initialize
    @seed_i = [0]
    @alias_i = @seed_i
    @seed_f = Array.new(0, 1.5)
    @alias_f = @seed_f
    @seed_s = Array.new(0, "")
    @alias_s = @seed_s
    @seed_w = [0]
    @alias_w = @seed_w
  end

  def add(i, f, s)
    @seed_i.push(i)
    @seed_f << f
    @alias_s << s
    @alias_w << s
    0
  end

  def read
    [@alias_i.last, @alias_f.sum, @seed_s.join(","), @seed_w]
  end
end

al = Aliased.new
al.add(4, 2.5, "a")
p al.read

# The same through a reader, a Struct member and an Array element: a name
# read out of them and pushed its own kind keeps the Array typed.
class Keeps
  attr_reader :kept_r
  def initialize = @kept_r = [0]
end
kp = Keeps.new
@kept_alias = kp.kept_r
@kept_alias << 5
KeptS = Struct.new(:kept_m)
ks = KeptS.new([0])
kept_l = ks.kept_m
kept_l << 6
kept_a = [0]
kept_e = [kept_a]
kept_e[0] << 7
p [kp.kept_r, ks.kept_m, kept_a]
