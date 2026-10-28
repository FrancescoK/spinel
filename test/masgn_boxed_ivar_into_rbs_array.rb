# A boxed element of a multiple assignment into an ivar an RBS signature
# pins to an Array (parslet's Cause#initialize: `@message, @children =
# message, children`, children nil or an Array). The element is unboxed
# into the slot, nil kept, as the single write `@children = children` is;
# the box went into the sp_PolyArray * field as it was and the C did not
# build.
class Cause
  def initialize(message, children)
    @children, @message = children, message
  end

  #: () -> Array[untyped]
  def children
    @children ||= []
  end

  #: () -> String
  def message = @message
end

p Cause.new("a", nil).children
p Cause.new("b", [1, "x"]).children
p Cause.new("c", [1, 2]).children
c = Cause.new("d", nil)
c.children << :k
p c.children
p c.message

# the element converted at its store allocates (a box holding an Integer
# Array converts to a new one), so the values after it are held across it
def label(i) = ARGV.size > 9 ? nil : "m#{i}" * 3
ok = (1..300).all? do |i|
  c = Cause.new(label(i), ARGV.size > 9 ? nil : [i, i + 1])
  c.message == "m#{i}" * 3 && c.children == [i, i + 1]
end
p ok
