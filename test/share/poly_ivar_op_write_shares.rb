# poly_ivar_store_receivers' shape, plus an operator write through the
# attribute (`b.items *= ","`, an Array joined into a String): the ivar can
# now hold a String, so the stores and clears through its reader are String
# changes and the Strings that meet it keep their handles. The share target
# checks that this program's C makes one.
class Box
  attr_accessor :items
  def initialize(keyed)
    @items = {}
    listed unless keyed
  end
  def listed = (@items = [])
  def reset = @items.clear
end

def show(x) = x

box = Box.new(true)
box.items["a"] = 1
box.reset
Box.new(false).items << 3
joined = Box.new(false)
joined.items.push("x", "y")
joined.items *= ","
name = +"title"
copy = name
p [show(name), copy], name.equal?(copy), show(box.items), show(joined.items)
