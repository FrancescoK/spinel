# spinel: rbs-seed-contradicted-return
# A seeded return answered through `flag || s`: the left operand is the value
# when truthy, and a Boolean that can be true is not a String (a Boolean
# that only ever answers false would not be: seed_ret_logic_operands.rb).
# The method answered a String-typed slot with the Boolean and faulted where
# CRuby answers true.
class SeedRetBranchOrBool
  def initialize(flag, s) = (@flag = flag; @s = s)
  def flag = @flag
  def s = @s
  def pick = (flag || s)
end

p SeedRetBranchOrBool.new(true, "s").pick
