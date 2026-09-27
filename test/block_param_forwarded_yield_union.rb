# A block's parameters are typed from the yields of the method they are
# passed to -- and from the yields of the methods that method hands its
# `&blk` on to. `visit` yields self and forwards the block to each_letter,
# which yields a String: typed from `yield self` alone, the parameter was
# the receiver's class and the yielded String was read as one.
class Word
  def initialize(s) = @s = s
  def to_s = "Word(#{@s})"
  def each_letter = @s.each_char { |ch| yield ch }
  def visit(&blk)
    yield self
    each_letter(&blk)
    relay(&blk)
  end
  def relay(&blk) = each_letter(&blk)
end
w = Word.new("ab")
w.visit { |x| print x.to_s, " " }
puts
w.relay { |x| print x.inspect, " " }
puts
r = w.visit { |x| x.to_s.size }
p r
