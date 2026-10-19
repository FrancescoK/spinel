# A method answering `new_string.tap { ... }` whose block takes no
# parameter answers a String no other name holds.
class Cursor
  def initialize(bytes) = (@bytes = bytes; @pos = 0)

  def take(count)
    raise ArgumentError, "short" if @pos + count > @bytes.bytesize

    @bytes.byteslice(@pos, count).tap { @pos += count }
  end

  def take_s(count)
    @bytes.byteslice(@pos, count).to_s.tap { @pos += count }
  end
end

c = Cursor.new(+"abcdefgh")
a = c.take(2)
a << "!"
b = c.take_s(3)
b << "?"
c2 = c.take(2)
p a, b, c2
