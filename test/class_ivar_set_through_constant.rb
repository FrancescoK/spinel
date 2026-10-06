# instance_variable_set / instance_variable_get with a literal name on a
# class named by a constant reach the class's own ivar -- the one its class
# methods read (tzinfo's StringDeduper picks its global instance so).
class Ded
  class << self
    attr_reader :global
  end
  def self.level = @level
  def dedupe(s) = "plain:" + s
end
class Unary < Ded
  def dedupe(s) = "unary:" + s
end
module Store
  def self.read = @data
end

Ded.instance_variable_set(:@global, Unary.new)
Ded.instance_variable_set("@level", 3)
Store.instance_variable_set(:@data, [1, 2])
p Ded.global.dedupe("x"), Ded.level, Store.read
p Ded.instance_variable_get(:@level), Store.instance_variable_get(:@data)
