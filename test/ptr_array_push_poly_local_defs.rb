# A boxed local pushed onto an Array is evidence of one class only through
# writes whose value is seen. A value it takes another way (a multiple
# assignment, a parameter) keeps the Array boxed: taken as its plain
# writes alone, the Array narrowed to one class and an element of another
# was read as that class.
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

  def text_masgn(x)
    t = @buffer.last
    unless Text === t
      t, _n = Text.new, 0
      @buffer << t
    end
    t.add(x)
  end

  def text_or(x)
    t = @buffer.last
    unless Text === t
      t = nil
      t ||= Text.new
      @buffer << t
    end
    t.add(x)
  end

  def shows = @buffer.map(&:show).join(" ")
end

b = Buf.new
b.brk; b.text_masgn("a"); b.text_masgn("b"); b.brk; b.text_or("c"); b.text_or("d")
puts b.shows

class A
  def show = "A"
end

class Box
  def initialize = @items = []

  def put(t)
    t = A.new if t.nil?
    @items << t
  end

  def shows = @items.map(&:show).join(" ")
end

x = Box.new
x.put(nil)
x.put(Brk.new)
x.put(A.new)
puts x.shows
