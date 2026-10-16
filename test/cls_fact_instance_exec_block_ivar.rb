# A block a method hands to instance_exec runs with the new object as self:
# its @r is that object's, not the class-level @r of the class body the block
# is written in. The class facts (#8530) read the class-level one, so the
# poly call had no arm for R (NoMethodError).
class R; def v = "R"; end
class S; def v = "S"; end
class Host
  def self.check(&block) = new.instance_exec(&block)
  def initialize
    @r = R.new
  end
  @r = S.new
  check { [S.new, @r].each { |o| puts o.v } }
end
