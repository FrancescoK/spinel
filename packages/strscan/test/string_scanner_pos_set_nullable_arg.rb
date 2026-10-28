# `sc.pos = n` as a value, where n is an Integer that can be nil: the
# binding answers its own Integer (a nil n raises TypeError before it
# answers), so the value is never the nullable argument. The method's
# answer below was emitted as an sp_oint read out of the binding's sp_int,
# which the C compiler rejected.
require "strscan"

class Src
  def initialize(s)
    @str = StringScanner.new(s)
  end

  def setpos(n)
    @str.pos = n
  end

  def bytepos=(n)
    @str.pos = n
  rescue RangeError
  end

  def bytepos
    @str.pos
  end
end

s = Src.new("hello")
n = ARGV.size > 5 ? nil : 4
p s.setpos(n)
p s.bytepos
s.bytepos = 3
p s.bytepos
p(s.send(:bytepos=, n))
p s.bytepos
m = ARGV.size > 5 ? 2 : nil
begin
  s.setpos(m)
rescue TypeError => e
  p e.class
end
p s.bytepos
