# StringIO had no readbyte or readchar binding, so both raised
# NoMethodError, typed or through a parameter that also receives a File.
# getbyte answered -1 at the end instead of nil, and putc with a String
# answered the byte instead of the String, so putc through a parameter
# that also receives a File raised too. Uses a temp file it deletes.
require "stringio"
require "tmpdir"

s = StringIO.new("hi")
p s.readbyte
p s.readchar
begin
  s.readbyte
rescue EOFError => e
  p e.message
end
begin
  s.readchar
rescue EOFError => e
  p e.class
end
p s.getbyte
p s.getc

t = StringIO.new
p t.putc("xy")
p t.putc(66)
p t.string

def take(io)
  p io.readbyte
  p io.readchar
  p io.getbyte
  p io.getbyte
  io.readbyte
rescue EOFError => e
  p e.class
end

path = File.join(Dir.tmpdir, "sp_stringio_readbyte_readchar_putc_#{Process.pid}.txt")
File.write(path, "abc")
File.open(path) { |f| take(f) }
take(StringIO.new("abc"))

def write_some(io)
  io.putc "x"
  io.putc 65
  io.putc "yz"
end

File.open(path, "w") { |f| write_some(f) }
s = StringIO.new
write_some(s)
p File.read(path)
p s.string
File.delete(path)
