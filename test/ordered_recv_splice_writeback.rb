# A sector write through an ivar whose index runs a method: Ruby reads the
# receiver first, and the poly `[]=` splice must still land in the ivar,
# not in a copy taken to order it.
class Image
  def initialize(bytes) = @bytes = bytes
  def offset(i) = i * 2
  def put(i, val) = @bytes[offset(i), 2] = val
  def bytes = @bytes
end

a = Image.new([0, 0, 0, 0])
a.put(1, [7, 8])
p a.bytes
s = Image.new("....")
s.put(0, "ab")
p s.bytes
