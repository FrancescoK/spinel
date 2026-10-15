# A block's value that map collects, read through a typed receiver's
# reader, is the String the receiver's instance variable holds, so a later
# change through the receiver shows in the collected Array, as in CRuby.
# The reader publishes its handle, and the plan boxes it, but no store
# marked the call for its pickup: the collected element was a copy of the
# bytes, and the Array kept the old text.
class Item
  def initialize(s) = @s = s
  def value = @s
  def bang = @s << "!"
  def add(x)
    @s << x
    self
  end
end

items = [Item.new(+"a"), Item.new(+"b")]
vs = items.map { |x| x.value }
items[0].bang
p vs, vs[0].equal?(items[0].value)

vs = items.map(&:value)
items[1].add("?")
p vs, vs[1].equal?(items[1].value)

vs = items.collect { |x| x.value }
vs << 1
items[0].add("*")
p vs

vs = items.map { |x| v = x.value; v }
items[1].bang
p vs

first = items.map { |x| x.value }.first
items[0].bang
p first

h = items.to_h { |x| [x.value.size, x.value] }
items[1].add("#")
p h

kept = items.filter_map { |x| x.value }
items[0].add("~")
p kept

def collect_values(list) = list.map { |x| x.value }
out = collect_values(items)
items[1].add("%")
p out, out.map(&:size)
