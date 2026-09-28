# An instance of a small immutable class stored in a class variable, or
# memoised into an ivar or global with ||=, lives in a slot that starts
# out nil.

class P1
  def initialize(x) = @x = x
  def x = @x
end
class P2
  def initialize(x) = @x = x
  def x = @x
end
class P3
  def initialize(x) = @x = x
  def x = @x
end
class P4
  def initialize(x) = @x = x
  def x = @x
end

class Holder
  @@origin = P1.new(4)
  def self.origin = @@origin
end
p Holder.origin.x

class Late
  def self.set = @@pt = P2.new(5)
  def self.pt = @@pt
end
Late.set
p Late.pt.x

$memo ||= P3.new(6)
p $memo.x

class Cache
  def pt = (@pt ||= P4.new(7))
end
p Cache.new.pt.x
