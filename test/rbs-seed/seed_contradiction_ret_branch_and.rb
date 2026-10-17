# spinel: rbs-seed-contradicted-return
# A seeded return answered through `&&`: the left operand is the value only
# when falsy, and a false there is not a String. The walk that lists the
# branches stopped at the operator, and the method answered nil where CRuby
# answers false.
class SeedRetBranchAnd
  def initialize(f, s) = (@f = f; @s = s)
  def flag = @f
  def s = @s
  def andl = (flag && s)
end

b = SeedRetBranchAnd.new(false, "x")
p b.andl
