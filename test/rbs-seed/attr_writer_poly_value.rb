# An --rbs Integer attr_accessor assigned a boxed value as a method's value:
# the store kept the sp_RbVal unconverted and the C did not compile (#4856).
# spinel: rbs-seed-check
class SeedAttrTarget
  attr_accessor :pc
  def initialize = @pc = 0
end
class SeedAttrDriver
  def initialize(t) = @t = t
  def run(src) = @t.pc = src[0] + 1
end
t = SeedAttrTarget.new
SeedAttrDriver.new(t).run([1, 2, :sym])
p t.pc
p SeedAttrDriver.new(t).run([7])
