require "stringio"

s = StringIO.new("äb€😀")
p s.getc
p s.getc
p s.readchar
p s.readchar
p s.pos
p s.getc

# a malformed or cut-short sequence comes out a byte at a time
s = StringIO.new("\xC3b\xE2\x82")
4.times { p s.getc }

# a binary buffer is bytes
p StringIO.new("\xC3\xA4".b).getc

w = StringIO.new
w.putc("äz")
w.putc("")
w.putc(65)
w.putc("€")
p w.string

StringIO.new("añ€").each_char { |c| p c }

def first_char(io) = io.getc
File.write("/tmp/spinel_stringio_multibyte_chars_#{Process.pid}.txt", "é!")
File.open("/tmp/spinel_stringio_multibyte_chars_#{Process.pid}.txt") { |f| p first_char(f) }
p first_char(StringIO.new("ü?"))

# invalid UTF-8 (overlong, surrogate, past U+10FFFF) is read a byte at a time
["\xE0\x80\x80", "\xED\xA0\x80", "\xF0\x80\x80\x80", "\xF4\x90\x80\x80", "\xE0\xA0\x80"].each do |bad|
  io = StringIO.new(bad.dup.force_encoding("UTF-8"))
  got = []
  while (ch = io.getc) do got << ch.bytes end
  p got
end
