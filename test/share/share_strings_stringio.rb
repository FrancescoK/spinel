# Flag-only. A StringIO reads and writes the String it is opened on, as
# CRuby's does: a write, <<, print, puts, putc and truncate change it, a
# change to it shows in the next read, #string is that String itself, and
# StringIO.new with no argument keeps a String of its own, which #string
# answers. Also through an ivar, StringIO.open's block, mode "w", a grown
# String, one only read, and a binary String read a byte at a time.
require "stringio"
def writes
  s = +"ab"
  io = StringIO.new(s)
  io.write("XY")
  p s
  s << "zz"
  p io.string
  p io.read
  p io.string.equal?(s)
end
def appends
  s = +"ab"
  io = StringIO.new(s, "a")
  io << "cd"
  io.print("e")
  io.puts("f")
  io.putc("g")
  p s
end
def truncates
  s = +"abcdef"
  io = StringIO.new(s)
  io.truncate(3)
  p s
  io.rewind
  io.write("Z")
  p s
end
def no_arg
  io = StringIO.new
  x = io.string
  io.write("hi")
  p x
  x << "!"
  p io.string
end
class Log
  def initialize(buf); @io = StringIO.new(buf); end
  def add(x); @io.puts(x); self; end
  def text; @io.string; end
end
def through_ivar
  b = +""
  Log.new(b).add("a").add("b")
  p b
end
def external_change
  s = +"one\n"
  io = StringIO.new(s)
  p io.gets
  s << "two\n"
  p io.gets
  p io.eof?
end
def direct_append
  io = StringIO.new
  io.string << "q"
  io.write("r")
  p io.string
end
def open_block
  s = +"ab"
  StringIO.open(s) { |io| io.write("Z") }
  p s
end
def read_only
  s = +"line\n"
  io = StringIO.new(s)
  p io.read
  p s
end
def mode_w
  s = +"abc"
  StringIO.new(s, "w")
  p s
end
def many
  s = +""
  io = StringIO.new(s)
  2000.times { |i| io.write(i.to_s) }
  p s.size
  p io.string.equal?(s)
end
writes; appends; truncates; no_arg
def binary_chars
  s = [0xe3, 0x81, 0x82, 0x41].pack("C*")
  io = StringIO.new(s)
  p io.getc
  io.write("Z")
  p s.bytes
end
through_ivar; external_change; direct_append; open_block; read_only; mode_w; many; binary_chars
