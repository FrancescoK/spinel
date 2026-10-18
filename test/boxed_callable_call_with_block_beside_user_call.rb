# A Method or a Proc read out of a slot that holds other values, called
# with a block where a class of the program also answers `call`: the
# block reaches the method's yield and the proc's &block, as it reaches
# the user `call`.
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

  def counted = [:counted, yield]

  def keyed(kind, by: 1) = [kind, by, yield]
end

class Caller
  def call(kind = :none, by: 0) = [:caller, kind, by, block_given? ? yield : :no_block]
end

class Edit
  def initialize(judge, mine) = (@judge = judge; @mine = mine)

  def check(other)
    @judge.call(:strict) do
      { mine: @mine, theirs: other } if @mine != other
    end
  end

  def cross = @judge.call(:loose) { raise "not run" }
end

rw = Checker.new
pick = ARGV.size
slots = [rw.judge, Caller.new, 5]
a = Edit.new(slots[pick], "x")
p a.check("x"), a.check("y"), a.cross
p Edit.new(slots[pick + 1], "x").check("y")

counter = [rw.method(:counted), Caller.new][pick]
p counter.call { :given }
keyed = [rw.method(:keyed), Caller.new][pick]
p keyed.call(:k, by: 2) { :kw_given }

wrapper = [proc { |v, &b| b ? b.call(v) : :no_block }, Caller.new][pick]
p wrapper.call(3) { |v| v * 100 }
p wrapper.call(4)
