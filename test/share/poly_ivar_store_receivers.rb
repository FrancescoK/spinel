# A Hash store, a clear or an append through a boxed instance variable --
# read directly, through an attribute reader or through a method answering
# it -- is no String mutation when every write of the ivar stores a Hash
# or an Array. Strings that only meet the receiver through a method
# answering its argument (`show`) are not changed in place, so they keep
# plain bytes: the share target checks that no String here is a handle.
class Box
  attr_accessor :items
  def initialize(keyed)
    @items = {}
    listed unless keyed
  end
  def listed = (@items = [])
  def put(k, v)
    @items[k] = v
  end
  def reset
    @items.clear
  end
end

class Shelf
  def initialize(keyed)
    @slots = {}
    @slots = [] unless keyed
  end
  def slots = @slots
end

def show(x) = x

box = Box.new(true)
box.items["a"] = 1
box.put("b", 2)
p show(box.items)
box.reset
box.items.clear
list = Box.new(false)
list.items << 3
list.items[1] = 4
p show(list.items)
Shelf.new(false).slots << 6
shelf = Shelf.new(true)
shelf.slots["c"] = 5
p show(shelf.slots)
shelf.slots.clear

name = +"title"
copy = name
pair = [show(name), copy]
p pair, name.equal?(copy), show(box.items), show(shelf.slots)
