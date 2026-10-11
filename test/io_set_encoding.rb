# IO#set_encoding picks the encoding a read with no length (and getc)
# answers: ASCII-8BIT, or UTF-8 / US-ASCII, by an Encoding, its name, an
# "ext:int" pair or nil for the default. It answers the IO, and binmode makes
# the handle ASCII-8BIT again. binmode? keeps what binmode set.
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_set_encoding_#{Process.pid}.txt")
File.binwrite(path, "h\xC3\xA9\n")

File.open(path) do |f|
  r = f.set_encoding(Encoding::BINARY)
  p r.equal?(f), f.binmode?
  s = f.read
  p s.encoding == Encoding::BINARY, s.length
end
File.open(path) do |f|
  f.binmode
  f.set_encoding("UTF-8")
  s = f.read
  p f.binmode?, s.encoding == Encoding::BINARY, s.length
end
File.open(path) do |f|
  f.set_encoding(Encoding::UTF_8)
  f.binmode
  p f.read.encoding == Encoding::BINARY
end
File.open(path) do |f|
  f.binmode
  f.set_encoding(nil)
  p f.read.encoding == Encoding::BINARY
end
File.open(path, "rb") do |f|
  f.set_encoding(Encoding::UTF_8)
  p f.read.length, f.binmode?
end
File.open(path) do |f|
  f.set_encoding("ASCII-8BIT:UTF-8")
  p f.read.length
end
File.open(path) do |f|
  f.set_encoding("binary", nil)
  p f.getc, f.getc.bytes
end
File.open(path) do |f|
  f.set_encoding("UTF-8", "UTF-8")
  p f.getc, f.getc
end

# an Encoding held in a variable, as an options object keeps one
class Options
  attr_accessor :encoding
  def initialize = @encoding = Encoding::UTF_8
end
opts = Options.new
out = File.join(Dir.tmpdir, "spinel_set_encoding_out_#{Process.pid}.txt")
File.open(out, "w") do |io|
  io.set_encoding opts.encoding
  io.write "café\n"
end
p File.binread(out).bytesize

f = File.open(path)
f.close
begin
  f.set_encoding("UTF-8")
rescue IOError => e
  p e.message
end
File.delete(path, out)
