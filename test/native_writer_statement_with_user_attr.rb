# A StringScanner's `pos=` as a statement, in a program where a user class
# also has a `pos=` writer, calls the StringScanner's own.
require "strscan"

class Wrap
  def initialize(input)
    @s = StringScanner.new(input)
    @column = 0
  end

  def scan(re)
    ret = @s.scan(re)
    @column += ret.length if ret
    ret
  end

  def unscan(s)
    @s.pos -= s.bytesize
    @column -= s.length
  end

  def rewind
    @s.pos = 0
    @column = 0
  end

  def pos = [@column, @s.pos]
end

class Info
  attr_accessor :pos

  def initialize = @pos = 0
end

w = Wrap.new("abc def")
t = w.scan(/\w+/)
p w.pos
w.unscan(t)
p w.pos
w.scan(/abc /)
p w.scan(/\S+/)
p w.pos
w.rewind
p w.pos
p w.scan(/\w+/)
i = Info.new
i.pos = 3
p i.pos
