# spinel: gc-stress
# A boxed receiver's `@a[i, n] = v` keeps v rooted while the index operands
# run: it was held by nothing, so an index operand that allocated collected
# it and the splice read a freed array (a TypeError or garbage, depending on
# when the collector ran).
class Image
  def initialize(n) = @bytes = n > 0 ? Array.new(1024, 0) : "x"
  def offset(t) = [t, t + 1, t * 2].sum * 8
  def bytes = @bytes

  def put(t, data)
    block = data.first(8)
    @bytes[offset(t), 8] = block + Array.new(8 - block.length, 0)
  end
end

image = Image.new(1)
200.times { |i| image.put(i % 30, [i % 256, 1, 2]) }
p image.bytes.sum, image.bytes.length
