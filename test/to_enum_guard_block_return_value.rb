# A method that answers `return to_enum(:m) unless block_given?` and, with a
# block, a value that leaves it from inside a block (`@a.each { |x| return x
# if yield(x) > 1 }`, then `self` or nil). The search for a value answered by
# the block form read the tail and the statements before it, not a `return`
# written in a block, so the method looked like an each-like one whose block
# form answers nothing: its return was pinned to the Enumerator, and the
# integer returned from the block was assigned into an Enumerator pointer (the
# C did not build). A return in a block is a value of the block form as much
# as a value tail is.
class C
  def initialize; @a = [1, 2, 3]; end

  def run
    return to_enum(:run) unless block_given?
    @a.each { |x| return x if yield(x) > 1 }
    self
  end

  def find_big
    return to_enum(:find_big) unless block_given?
    @a.each { |x| return x if yield(x) > 5 }
    nil
  end
end

c = C.new
p c.run { |x| x }
p c.run { |x| x * 0 }.equal?(c)
p c.run.class
p c.find_big { |x| x * 3 }
p c.find_big { |x| x }
p c.find_big.class

# a value that is a literal Array or an interpolated String is a value too,
# a `return self` is not (the method keeps the pin, and the call with a block
# answers the receiver), and a `return` in a lambda leaves the lambda, not the
# method
class E
  def initialize; @a = [1, 2, 3]; end

  def pair_in_block
    return to_enum(:pair_in_block) unless block_given?
    @a.each { |x| return [x, 0] if yield(x) > 1 }
    nil
  end

  def str_in_block
    return to_enum(:str_in_block) unless block_given?
    @a.each { |x| return "s#{x}" if yield(x) > 1 }
    nil
  end

  def self_in_block
    return to_enum(:self_in_block) unless block_given?
    @a.each { |x| return self if x > 5 }
    @a.each { |x| yield x }
    self
  end

  def self_returned
    return to_enum(:self_returned) unless block_given?
    @a.each { |x| yield x }
    return self
  end

  def list_tail
    return to_enum(:list_tail) unless block_given?
    @a.each { |x| yield x }
    [1, 2]
  end

  def lambda_return
    return to_enum(:lambda_return) unless block_given?
    clamp = ->(x) { return 0 if x < 2; x }
    @a.each { |x| yield clamp.(x) }
    self
  end
end

e = E.new
p e.pair_in_block { |x| x }
p e.str_in_block { |x| x }
p e.self_in_block { |x| x }.equal?(e)
p e.self_in_block.class
p e.self_returned { |x| x }.equal?(e)
p e.list_tail { |x| x }
p e.lambda_return { |x| x }.equal?(e)
p e.pair_in_block.class
p e.lambda_return.class

# the Enumerable idiom: an each that returns self early, in its body or in a block
class F
  include Enumerable
  def initialize(a) = @a = a

  def each
    return to_enum(:each) unless block_given?
    return self if @a.empty?
    @a.each { |x| yield x }
    self
  end
end

f = F.new([3, 1, 2])
en = f.each
p en.class, en.next, en.to_a
p f.map { |x| x * 2 }, f.sort.reverse, f.each_slice(2).to_a, f.first, f.min
p F.new([]).map { |x| x }, F.new([]).each { }.class
