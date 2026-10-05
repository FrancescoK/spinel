# Flag-only: without the flag (as on master) the C for these reads does not compile.
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
File.delete(path)
