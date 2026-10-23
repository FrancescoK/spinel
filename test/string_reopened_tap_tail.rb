# The two String representations refused this program; with one it answers as CRuby.
# A reopened String#tap answers what it likes: a method whose tail taps a
# new String with it does not answer a new String, so the shared String it
# answers, kept and changed, stays refused.
class Holder
  def initialize = (@s = +"shared")
  def s = @s
end
H = Holder.new

class String
  def tap
    yield self
    H.s
  end
end

class Cursor
  def initialize(bytes) = (@bytes = bytes; @pos = 0)

  def take(count)
    @bytes.byteslice(@pos, count).tap { @pos += count }
  end
end

c = Cursor.new(+"abcdefgh")
a = c.take(2)
a << "!"
p a, H.s
