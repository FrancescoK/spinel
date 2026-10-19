# A read into a buffer answers the buffer itself. Boxed as an Array's
# element, also as the arm of a rescue modifier whose other arm is a Symbol
# (a poly value), it is the buffer's String, so a change through the
# element reaches the buffer, as in CRuby. The read was boxed as a copy of
# the buffer's bytes.
require "tmpdir"
path = File.join(Dir.tmpdir, "sp_box_outbuf_#{Process.pid}.txt")
File.write(path, "hello world")
File.open(path) do |f|
  b = +"old"
  x = [(f.readpartial(2, b) rescue :e)]
  x[0] << "Z"
  p b, x[0].equal?(b)
  y = [f.read(2, b)]
  y[0] << "Y"
  p b, y[0].equal?(b)
  z = [(f.pread(2, 0, b) rescue :e), 1]
  z[0] << "X"
  p b, z[0].equal?(b)
end
f = [File.open(path), 1][ARGV.size]
b = +"boxed"
w = [(f.readpartial(2, b) rescue :e)]
w[0] << "W"
p b, w[0].equal?(b)
f.close
File.delete(path)
