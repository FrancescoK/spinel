# A sector write through an ivar whose index runs a method: Ruby reads the
# receiver first, and the poly `[]=` splice must still land in the ivar,
# not in a copy taken to order it. (String.new: a literal is frozen.)
class Image
  def initialize(bytes) = @bytes = bytes
  def offset(i) = i * 2
  def put(i, val) = @bytes[offset(i), 2] = val
  def bytes = @bytes
end

a = Image.new([0, 0, 0, 0])
a.put(1, [7, 8])
p a.bytes
s = Image.new(String.new("...."))
s.put(0, "ab")
p s.bytes

# A string literal that spells a temp store is data, not the slot write:
# the receiver is still read before the index runs.
class Swap
  def initialize = @data = ["a", "b", "c"]
  def swap(i) = (@data = ["z", "y", "x"]; i)
  def put(i) = @data[swap(i)] = "_t1 = _t2 = _t3 = _t4 = _t5 = _t6 = _t7 = _t8 = _t9 = _t10 ="
  def data = @data
end
w = Swap.new
w.put(0)
p w.data
