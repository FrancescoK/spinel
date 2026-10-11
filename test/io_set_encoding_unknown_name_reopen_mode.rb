# IO#set_encoding with an external name no encoding has stands for none
# given, as in CRuby: a read answers the default encoding, or the internal
# one passed beside it, not whatever an earlier call or "rb" chose. And
# IO#reopen with a mode replaces the handle's mode, so an earlier binmode
# or set_encoding no longer decides what a read answers; reopen with no
# mode keeps them.
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_set_enc_unknown_#{Process.pid}.txt")
File.binwrite(path, "h\xC3\xA9llo\n")

def binary_read?(path, mode)
  f = File.open(path, mode)
  yield f
  s = f.read
  f.close
  s.encoding == Encoding::BINARY
end

p binary_read?(path, "rb") { |f| f.set_encoding("bogus", "UTF-8") }
p binary_read?(path, "rb") { |f| f.set_encoding("bogus") }
p binary_read?(path, "rb") { |f| f.set_encoding("bogus", nil) }
p binary_read?(path, "r") { |f| f.set_encoding("bogus", "ASCII-8BIT") }
p binary_read?(path, "r") { |f| f.set_encoding("ASCII-8BIT"); f.set_encoding("bogus") }
p binary_read?(path, "r") { |f| f.binmode; f.set_encoding("bogus") }

f = File.open(path, "r")
f.set_encoding("UTF-8")
f.reopen(path, "rb")
p f.read(3).encoding == Encoding::BINARY, f.getc.encoding == Encoding::BINARY
f.close

f = File.open(path, "r")
f.set_encoding("ASCII-8BIT")
f.reopen(path, "r")
p f.read.encoding == Encoding::BINARY
f.close

f = File.open(path, "r")
f.binmode
f.reopen(path, "r")
p f.read.encoding == Encoding::BINARY, f.binmode?
f.close

f = File.open(path, "r")
f.set_encoding("ASCII-8BIT")
f.reopen(path)
p f.read.encoding == Encoding::BINARY
f.close

File.delete(path)
