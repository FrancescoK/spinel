# A String a program method hands out of the Array it holds is the Array's
# element: an append through the method's result, or through a block its
# iterator forwards, reaches the element (webrick's HTTPUtils header values).
class Held
  def initialize(values = []) = @values = values
  def <<(v) = (@values << v; self)
  def add(v) = @values << v
  def [](i) = @values[i]
  def first = @values[0]
  def each(&block) = @values.each(&block)
end

h = Held.new
h.add(+"x")
h[0] << "!"
p h[0]
h.first << "?"
p h.first
x = h[0]
x.upcase!
p h[0]

e = Held.new
e << +" a "
e.each { |s| s.strip! }
p e[0]

# out of a Hash with a default value: the receiver is read out of a poly slot
header = Hash.new(Held.new([].freeze))
header["k"] = Held.new unless header.key?("k")
header["k"] << +" one"
header["k"][-1] << " " << "two"
p header["k"][0]
header.each { |_, values| values.each { |v| v.gsub!(/\A +/, "") } }
p header["k"][0]
p header["missing"][0]
