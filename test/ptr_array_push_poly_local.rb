# A boxed local pushed onto an Array is evidence of the classes its writes
# hold. `t = @buffer.last` and `t = Text.new` both reach `@buffer << t`, so
# the Array holds a Text beside the Brk objects and stays boxed. Taken as no
# evidence, the Array narrowed to an unboxed Array of Brk: `Text === t` then
# folded to false, and each text call pushed a new Text.
class Text
  def initialize = @s = +""
  def add(x) = @s << x
  def show = "T(#{@s})"
end

class Brk
  def show = "B"
end

class Buf
  def initialize = @buffer = []
  def brk = @buffer << Brk.new

  def text(x)
    t = @buffer.last
    unless Text === t
      t = Text.new
      @buffer << t
    end
    t.add(x)
    nil
  end

  def size = @buffer.size
  def shows = @buffer.map(&:show).join(" ")
end

b = Buf.new
b.brk
b.text("a")
b.text("b")
b.brk
b.text("c")
p b.size
puts b.shows

