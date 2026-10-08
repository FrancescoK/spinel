# A String handed through a POLY parameter (an Integer also reaches it) and
# aliased by a method that answers its argument, or stored through an
# attr_writer whose attribute the program appends to: the alias is the
# caller's String, so the append reaches it.
class Ident
  def id(x) = x
  def entry(data)
    return data.to_s if data.is_a?(Integer)
    w = id(data)
    w << "!"
    nil
  end
end

class Boxed
  attr_accessor :box
  def entry(data)
    return data.to_s if data.is_a?(Integer)
    self.box = data
    box << "?"
    nil
  end
end

class Cart
  attr_writer :slot
  attr_reader :slot
  def fill(item)
    return item.to_s if item.is_a?(Integer)
    self.slot = item
    nil
  end
  def add(x) = (slot << x)
end

a = +"a"
Ident.new.entry(1)
Ident.new.entry(a)
b = +"b"
Boxed.new.entry(1)
bx = Boxed.new
bx.entry(b)
c = +"c"
cart = Cart.new
cart.fill(2)
cart.fill(c)
cart.add("#")
p a, b, c, bx.box
