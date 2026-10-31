# spinel: gc-stress
# An object operand beside another converts through its own to_ary after
# the frozen entry, in turn with the others, and each converted Array is
# kept as it was before a later conversion runs.
$events = []
class TurnSource
  def initialize(tag, items)
    @tag = tag
    @items = items
  end

  def items = @items

  def to_ary
    $events << @tag
    @items
  end
end
class StrTurnSource
  def initialize(items) = @items = items

  def to_ary
    $events << :str
    @items
  end
end
class TurnMutator
  def initialize(victim) = @victim = victim

  def to_ary
    $events << :mutator
    @victim.items << 99
    [7]
  end
end
def turn_argument(tag, value)
  $events << tag
  value
end
def turn_mixed(f) = f ? 3 : [4]

a = [1]
a.concat(TurnSource.new(:first, [2, 3]), [5])
p a
a.concat([6], TurnSource.new(:second, [7]))
p a
a.concat(TurnSource.new(:third, [8]), turn_mixed(false))
p a
p $events

$events = []
b = [1]
b.concat(turn_argument(:arg1, TurnSource.new(:conv1, [2])), turn_argument(:arg2, TurnSource.new(:conv2, [3])))
p b
p $events

$events = []
src = TurnSource.new(:shared, [10, 11])
c = [0]
c.concat(src, TurnMutator.new(src))
p c
p src.items
p $events

$events = []
d = [1].freeze
begin
  d.concat(turn_argument(:arg, TurnSource.new(:conv, [2])), [3])
rescue => err
  p err.class
end
p $events

$events = []
e = [1]
begin
  e.concat(TurnSource.new(:before, [2]), turn_mixed(true))
rescue TypeError => err
  p err.message
end
p e
p $events

s = ["a"]
s.concat(StrTurnSource.new(["b", "c"]), ["d"])
p s
p $events
