# spinel: share
# spinel: gc-minor
# Passing a String ivar as a keyword keeps mutation out of a value copy.
class PackAccumulator
  def initialize = (@b = String.new)
  def add(n) = [n].pack("C", buffer: @b)
  def bytes = @b.bytes
end
acc = PackAccumulator.new
32.times { |i| acc.add(65 + i % 3) }
p acc.bytes
