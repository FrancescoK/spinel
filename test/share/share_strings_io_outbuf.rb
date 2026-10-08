# A read into a buffer the rule shares fills that buffer and answers it.
require "tmpdir"
path = File.join(Dir.tmpdir, "sp_share_outbuf_#{Process.pid}.txt")
File.write(path, "hello world")
File.open(path) do |f|
  b = +""; c = b; c << ""
  r = f.sysread(3, b); p r, b, r.equal?(b), c
  r = f.readpartial(3, b); p r, b, r.equal?(b)
  r = f.read(2, b); p r, b, r.equal?(b)
end
File.open(path) do |f|
  b = "fixed".freeze
  p((f.sysread(3, b) rescue $!.class))
end
File.open(path) do |f|
  b = +"old"; c = b; c << ""
  r = f.read(50, b)
  p r.equal?(b), c
  p f.read(1, b), b, c
  p((f.readpartial(1, b) rescue $!.class), b)
end
File.open(path) do |f|
  b = +"old"; c = b; c << ""
  r = f.pread(2, 1, b)
  p r, b, c, r.equal?(b)
  p((f.pread(1, 100, b) rescue $!.class), b)
end
File.open(path) do |f|
  b = +"old"; c = b; c << ""; b.freeze
  p((f.read(1, b) rescue $!.class), c, f.pos)
end
# An accumulator handle uses its slot even when no alias makes it shared.
File.open(path) do |f|
  b = String.new(capacity: 16)
  f.readpartial(4, b)
  b << f.readpartial(4) while b.bytesize < 7
  p b
end
File.delete(path)
