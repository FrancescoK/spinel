# In a Struct.new or Data.define block self is the class being built: a call
# on self reaches it, an ivar written there is the class's own, and self
# handed elsewhere is the class, which by the time it is read back has its
# name (the constant is written when the block returns).
module Registry
  def self.add(k) = (@all ||= []) << k
  def self.all = @all
end

Point = Struct.new(:x, :y) do
  Registry.add(self)
  @made = 0
  p self.members, self.class, self.method_defined?(:x)
  p self == Registry.all.last
  def self.made = @made
  def self.build(x) = (@made += 1; new(x, 0))
  def norm = x + y
end

Pair = Data.define(:a) do
  Registry.add(self)
  p self.members
end

p Registry.all, Point.build(3).norm, Point.made
