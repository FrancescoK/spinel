# A Method or a Proc read out of a slot that holds other values, called
# with a block: the block reaches the method's yield, its &block, and a
# proc's &block parameter.
class Checker
  def initialize
    @rules = { strict: :raise, loose: :accept }
    @judge = method(:decide)
  end
  attr_reader :judge

  def decide(event)
    return :accepted if @rules[event] == :accept
    return :none unless (values = yield)
    [event, values]
  end

  def each_pair_of(a, &blk) = a.each_slice(2).map { |x, y| blk.call(x, y) }
end

class Edit
  def initialize(judge, mine) = (@judge = judge; @mine = mine)

  def check(other)
    @judge.call(:strict) do
      { mine: @mine, theirs: other } if @mine != other
    end
  end

  def loose = @judge.call(:loose) { raise "not run" }
end

rw = Checker.new
slots = [rw.judge, 5, "x"]
a = Edit.new(slots[ARGV.size], "x")
p a.check("x"), a.check("y"), a.loose

pairer = [rw.method(:each_pair_of), nil][ARGV.size]
p pairer.call([1, 2, 3, 4]) { |x, y| x * y }
sum = ->(x, y) { x + y }
p pairer.call([5, 6], &sum)

wrapper = [proc { |v, &b| b ? b.call(v) : :no_block }, 1][ARGV.size]
p wrapper.call(3) { |v| v * 100 }
p wrapper.call(4)
