# a class whose own reads forward to its Array's, handing on their block:
# the Array's take / slice / first / values_at / dig, reached through the
# dispatch the class's methods open, leave the block unused and answer as
# they would without it

class C
  def initialize(a) = (@a = a)
  def to_a = @a
  def take(*args, &blk) = to_a.take(args[0], &blk)
  def slice(*args, &blk) = to_a.slice(args[0], &blk)
  def first(*args, &blk) = to_a.first(args[0], &blk)
  def values_at(*args, &blk) = to_a.values_at(args[0], &blk)
  def dig(*args, &blk) = to_a.dig(args[0], &blk)
end
C.new([1, 2])
c = C.new([[7, 8], 66])
p c.take(1)
p c.slice(1)
p c.slice(0)
p c.first(2)
p c.values_at(1)
p c.dig(0)
