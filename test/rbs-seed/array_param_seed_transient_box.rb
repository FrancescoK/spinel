# A box an Array parameter seed sees while the types are still settling must
# not drop the seed. `@codes[a]` reads a nested-Array ivar that is an untyped
# Array for a few rounds (`set_codes` stores a parameter not typed yet); its
# element was a box then, and the `Array[Integer]` seed of `combine` gave way
# to it for good. The parameter re-derived from the same transient and stayed
# boxed, though every argument it is handed settles as an Integer Array: each
# call boxed its arguments and every read in the loop dispatched at run time.
# The settled types decide now (an_settle_seed_boxes); a box that is still one
# there drops the seed as before (rbs_array_seed_box.rb).
# spinel: rbs-seed-check
class SeedBoxPlan
  def initialize(n)
    @codes = Array.new(n) { Array.new(0, 0) }
  end

  def set_codes(k, codes)
    @codes[k] = codes
  end

  def build(a, b)
    SeedBoxPair.combine(@codes[a], @codes[b])
  end
end

class SeedBoxSource
  def initialize(n)
    @codes = Array.new(n) { |k| [k, k + 1, k + 2] }
  end

  def code(k)
    @codes[k]
  end
end

module SeedBoxPair
  def self.combine(ci, cj)
    out = Array.new(ci.length, 0)
    i = 0
    while i < ci.length
      out[i] = ci[i] * 10 + cj[i]
      i += 1
    end
    out
  end
end

src = SeedBoxSource.new(2)
plan = SeedBoxPlan.new(2)
plan.set_codes(0, src.code(0))
plan.set_codes(1, src.code(1))
p SeedBoxPair.combine(src.code(0), src.code(1))
p plan.build(0, 1)
