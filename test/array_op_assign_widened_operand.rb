# An Array op-assign whose operand is built from an Integer the program
# computes (`[offset >> 4]`). Under --int-overflow=promote that operand is a
# poly array, so `|=` `&=` `-=` `+=` write the combination as one: the slot
# widens with it, on an ivar, a class variable, an attribute, a global and
# a local. Left an Integer array, the ivar's `|=` was the raw C `|` between
# two array pointers, and the local's and the attribute's were refused.
# Same answers in every mode.
class Flash
  @@seen = [0]
  def initialize = @erasing = [0]
  def erase(offset)
    @erasing |= [offset >> 4]
    @@seen += [offset >> 2]
  end
  def drop(offset) = @erasing -= [offset >> 4]
  def keep(offset) = @erasing &= [offset >> 4, 0]
  def seen = @@seen
  attr_reader :erasing
end
f = Flash.new
f.erase(0x10)
f.erase(0x12)
f.erase(0x20)
p f.erasing, f.seen
f.drop(0x20)
p f.erasing
f.keep(0x10)
p f.erasing

class Box
  attr_accessor :items
  def initialize = (@items = [1])
end
def three = 3
box = Box.new
box.items |= [three]
box.items += [three * 2]
p box.items
box.items = [5]
p box.items

$pages = [1]
def mark(n) = $pages |= [n * 2]
mark(3)
mark(1)
p $pages

def collect(xs)
  acc = [0]
  xs.each { |x| acc |= [x / 2] }
  acc += [xs.size * 3]
  acc
end
p collect([4, 5, 9])
