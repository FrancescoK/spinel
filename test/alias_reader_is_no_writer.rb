# `alias :to_s :name` over an attr_accessor aliases the reader only: there
# is no `to_s=`, so a boxed receiver's `to_s=` reaches the class that does
# define one (a Struct member here), and this class raises NoMethodError
class Item
  attr_accessor :name
  alias :to_s :name
  def initialize(n) = @name = n
end

Loc = Struct.new(:path, :to_s)

def set_to_s(o, v) = o.to_s = v

item = Item.new("x")
loc = Loc.new("p", "t")
set_to_s([loc, item][0], "u")
p loc.to_s
begin
  set_to_s([item, loc][0], "v")
rescue NoMethodError => e
  puts e.class
end
p item.to_s
{ name: "z" }.each { |k, v| item.send("#{k}=", v) }
p item.to_s
