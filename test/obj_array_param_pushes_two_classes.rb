# A helper that pushes its argument into the array it is handed, called with
# objects of two classes: each array holds what was pushed into it.
class Meth
  attr_reader :name
  def initialize(name) = @name = name
end

class Const
  attr_reader :value, :name
  def initialize(name)
    @value = 42
    @name = name
  end
  def shout = name.upcase
end

def add_to(array, thing)
  array << thing
end

methods = [Meth.new("a")]
consts = [Meth.new("b")]
add_to methods, Meth.new("c")
add_to consts, Const.new("x")
p methods.map(&:name), consts.map(&:name), consts.map(&:class)
p consts.last.shout, consts.last.value

# through a second helper that hands both on
def add_any(list, x) = add_to(list, x)

mixed = [Const.new("y")]
add_any mixed, Meth.new("d")
add_any mixed, Const.new("z")
p mixed.map(&:name)
p mixed.select { |e| e.is_a?(Const) }.map(&:shout)

# an instance method, and an ivar
class Registry
  attr_reader :items
  def initialize
    @items = [Meth.new("e")]
  end
  def store(list, item)
    list.push item
  end
  def add(item) = store(@items, item)
end

reg = Registry.new
reg.add Meth.new("f")
other = [Meth.new("g")]
reg.store other, Const.new("w")
p reg.items.map(&:name), other.map(&:name), other.last.shout
