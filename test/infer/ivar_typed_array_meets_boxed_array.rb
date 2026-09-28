# A slot that holds an Array under every write stays an ARRAY when the two
# array kinds disagree, instead of widening to a boxed value (#5521).
#
# @xs settles as an int array from its pushes -- the #5499 re-narrow resets
# the slot and the pushes re-fold before the pushed value settles -- and the
# next write hands it a boxed array. Unifying int_array with poly_array
# answered the plain poly SCALAR, so the slot came out sp_RbVal and every
# reader of it was boxed; campfire's Nokogiri NodeSet#@nodes is this shape.
class Bag
  def initialize
    @xs = []
  end
  def add(n)
    @xs << n
  end
  def replace(a)
    @xs = a
  end
  def first
    @xs[0]
  end
  def size
    @xs.length
  end
end
b = Bag.new
b.add(1)
b.add(2)
p b.size
b.replace([1, "two", 3.0])
p b.first
p b.size

# The control: two TYPED array kinds still box. Their readers are typed from
# the writes and the box is what keeps them consistent, so this slot is a
# boxed value, not a boxed array -- the #4196 rule, which #5521 does not move.
class Mixed
  def initialize
    @ys = []
  end
  def ints(a)
    @ys = a
  end
  def floats(a)
    @ys = a
  end
  def peek
    @ys
  end
end
m = Mixed.new
m.ints([1, 2])
p m.peek
m.floats([1.5, 2.5])
p m.peek

# The same rule on the transplanted copies of a module's ivar. A module
# included into several classes gets one slot per class, and the copies are
# merged on their own path -- which did not carry the rule at all, so the
# copy that saw the typed array first came out sp_RbVal while its siblings
# stayed sp_PolyArray *: three copies of one module ivar, disagreeing.
module Holder
  def seed
    @items = []
  end
  def add(n)
    @items << n
  end
  def replace(a)
    @items = a
  end
  def peek
    @items
  end
end
class Counter
  include Holder
  def initialize; seed; end
end
class Mixer
  include Holder
  def initialize; seed; end
end
cn = Counter.new
cn.add(1)
cn.add(2)
p cn.peek
mx = Mixer.new
mx.replace([1, "two", 3.0])
p mx.peek
