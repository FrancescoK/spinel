# The transient of array_param_seed_transient_box.rb, reaching an Array return
# seed and an Array ivar pin instead of a parameter. `@codes[a]` is an untyped
# Array's element for the first rounds (`set_codes` stores a parameter not
# typed yet), so `row`'s `Array[Integer]` return and the `Array[Integer]` pin
# of @last gave way to its box on the first round, for good: `row` answered a
# box through the checked wrapper and @last was a boxed field, though both
# only ever hold an Integer Array. The settled types decide now.
# spinel: rbs-seed-check
class SeedBoxRetPlan
  def initialize(n)
    @codes = Array.new(n) { Array.new(0, 0) }
    @last = Array.new(0, 0)
  end

  def set_codes(k, codes)
    @codes[k] = codes
  end

  def row(a)
    @codes[a]
  end

  def keep(a)
    @last = @codes[a]
    @last.length
  end
end

class SeedBoxRetSource
  def initialize(n)
    @codes = Array.new(n) { |k| [k, k + 1, k + 2] }
  end

  def code(k)
    @codes[k]
  end
end

src = SeedBoxRetSource.new(2)
plan = SeedBoxRetPlan.new(2)
plan.set_codes(0, src.code(0))
plan.set_codes(1, src.code(1))
p plan.row(1)
p plan.keep(0)
p plan.row(0).equal?(src.code(0))
