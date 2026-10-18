# spinel: rbs-seed-contradicted-return
# A seeded return answered through `||`: the left operand is the value when
# truthy and the right one when not, so the right one is judged on its own
# (seed_contradiction_ret_branch.rb). `falsev` answers false, which a method
# declared to return String cannot hold; the walk that lists the branches
# stopped at the operator, and the method answered nil where CRuby answers
# false.
class SeedRetBranchOr
  def initialize(s, t) = (@s = s; @t = t)
  def s = @s
  def falsev = false
  def or3 = (s or @t or falsev)
  def or2 = (s || falsev)
end

b = SeedRetBranchOr.new(nil, nil)
p b.or3, b.or2
