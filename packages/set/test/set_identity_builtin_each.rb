# An identity Set filled from the blocks of a builtin's each, times and
# reverse_each (an Array, a Range, an Integer, a Hash): those iterators
# drop the block's value, though a class of the program's has an each and
# a times that keep theirs. Only a Span or a Clock answers those, so the
# Set is followed, only the calls on it are checked, and a boxed include?
# with a String elsewhere compiles. Keys all equal to one another are
# told apart by identity.
require "set"

class Key
  def initialize(n) = @n = n
  def n = @n
  def ==(o) = true
  def eql?(o) = true
  def hash = 0
end

class Span
  def initialize(r) = @r = r
  def each(&blk) = @r.map(&blk)
end

class Clock
  def times
    yield 0
  end
end

class Seen
  def initialize = @seen = Set.new.compare_by_identity

  def fill
    [1, 2].each { |i| @seen << Key.new(i) }
    (3..4).each { |i| @seen.add(Key.new(i)) }
    2.times { |i| @seen << Key.new(i) }
    [5, 6].reverse_each { |i| @seen.add(Key.new(i)) }
    { a: 7 }.each { |_, v| @seen << Key.new(v) }
    @seen.size
  end

  def seen?(k) = @seen.include?(k)
end

def pick(a, i) = a[i]
s = Seen.new
p s.fill, s.seen?(Key.new(1))
p Set[Key.new(1)].include?(Key.new(2))
p Span.new(1..3).each { |i| i * 2 }
p Clock.new.times { |i| i + 1 }
p pick([%w[a b], Set["a"]], 1).include?("a"), pick([%w[a b], Set["a"]], 0).include?("b")
