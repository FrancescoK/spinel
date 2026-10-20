# A call on a boxed receiver that no class the box can hold answers (Route
# is never made, so the box holds a Store or an Integer) raises
# NoMethodError before it answers. The share walk took it as a call it
# does not follow, joined its String to UNKNOWN, and refused handing it to
# a parameter that shares: no String ever flows from it.
class Route
  attr_reader :int_params
  def initialize(int_params = +"") = @int_params = int_params
end

class Store
  def initialize(name) = @name = name
  def name = @name
end

def consume(s)
  s << "!"
  s
end

kept = +"kept"
p consume(kept), kept
box = [Store.new(+"s"), 1][0]
begin
  p consume(box.int_params)
rescue NoMethodError => e
  p e.class
end
p box.name
