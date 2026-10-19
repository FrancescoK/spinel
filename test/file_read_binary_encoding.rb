# File.read with an external BINARY encoding reads as File.binread does,
# where the options hash reached the length slot and the C did not compile.
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_read_bin_enc_#{Process.pid}")
File.write(path, "café")
a = File.read(path, encoding: "BINARY")
p a, a.encoding, a.bytesize
b = File.read(path, encoding: Encoding::ASCII_8BIT)
p b.encoding, b == a
c = File.read(path, 3, encoding: "ascii-8bit")
p c, c.encoding
d = File.read(path, external_encoding: Encoding::BINARY)
p d.encoding
e = File.read(path, encoding: "UTF-8")
p e, e.encoding
File.delete(path)

class Log
  def initialize(path)
    @path = path
  end

  def text
    File.read(@path, encoding: "BINARY")
  rescue Errno::ENOENT
    ""
  end
end
p Log.new(path).text
