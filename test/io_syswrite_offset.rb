# IO#syswrite writes straight to the descriptor, each write after the last:
# the stream was then sought back to stdio's stale cached offset, so a second
# syswrite overwrote the first ("c", "ab", "1" left "c1b"). The position the
# file reports after it, and a buffered write after it, follow the bytes
# written. A descriptor with no offset of its own (a pipe, a terminal) takes
# syswrite without the ESPIPE the seek raised.
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_syswrite_offset_#{Process.pid}.txt")
f = File.open(path, "w")
p f.syswrite("c"), f.syswrite("ab"), f.syswrite("1")
p f.pos
f.write("Z")
f.close
p File.read(path)
File.open(path, "a") { |g| g.syswrite("+"); g.syswrite("-") }
p File.read(path)
File.delete(path)

r, w = IO.pipe
p w.syswrite("pi"), w.syswrite("pe")
w.close
p r.read
$stdout.syswrite("out\n")
puts "after"
