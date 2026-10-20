# A method that answers `return to_enum(:m) unless block_given?` is pinned to
# the Enumerator for the blockless call. A call with a block answered the pin
# too, when the value the method falls off its end with is not `self`: an
# iteration's tail (`@a.each_with_index { ... }`, whose value is the array), a
# nil tail beside a `return self` written in a block. The block form's value
# was assigned into an Enumerator slot as a zero (nil, where CRuby answers
# the array) or the C did not build. A call with a block answers the join of
# the values the body returns other than the guard's.
class Pairs
  def initialize; @a = [1, 2, 3]; end

  def each_pair
    return to_enum(:each_pair) unless block_given?
    @a.each_with_index { |x, i| yield x, i }
  end

  def each_plain
    return to_enum(:each_plain) unless block_given?
    def helper = (return 5)
    @a.each { |x| yield x }
  end
end

c = Pairs.new
p c.each_pair.to_a
p c.each_pair { |a, b| }
p c.each_pair.next
p c.each_pair.class
p c.each_plain.to_a
p c.each_plain { |x| x }
p c.each_plain.class

class Node
  def initialize(v, nx = nil) = (@v = v; @nx = nx)

  def each
    return enum_for(:each) unless block_given?
    n = self
    while n
      yield n.v
      n = n.nx
    end
    self
  end

  def find_first
    return to_enum(:find_first) unless block_given?
    each { |v| return self if yield(v) }
    nil
  end

  attr_reader :v, :nx
end

l = Node.new(1, Node.new(2))
p l.each.to_a, l.each { }.equal?(l)
p l.find_first { |v| v == 2 }.equal?(l), l.find_first { false }
p l.find_first.class

# a path that answers nil beside an Integer: the join is boxed
class Counter
  def initialize(n) = @n = n

  def each
    return to_enum(:each) unless block_given?
    return nil if @n == 0
    @n.times { |i| yield i }
  end

  def each_bare
    return to_enum(:each_bare) unless block_given?
    return if @n == 0
    @n.times { |i| yield i }
  end

  def each_early
    return to_enum(:each_early) unless block_given?
    @n.times { |i| return nil if i > 5; yield i }
  end
end

p Counter.new(3).each { }, Counter.new(0).each { }
x = Counter.new(0).each { }
p x.nil?, Counter.new(2).each.to_a
p Counter.new(2).each_bare { }, Counter.new(0).each_bare { }
p Counter.new(9).each_early { }, Counter.new(2).each_early { }
