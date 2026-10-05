# IO class methods (read/write/readlines/foreach/pipe/copy_stream/sysopen),
# Kernel#open, read-into-buffer, puts with an Array, readlines separators.
File.write("/tmp/sp_io4_#{Process.pid}.txt", "one\ntwo\n")
p IO.read("/tmp/sp_io4_#{Process.pid}.txt")
p IO.readlines("/tmp/sp_io4_#{Process.pid}.txt")
IO.write("/tmp/sp_io4_#{Process.pid}.txt", "abc")
p IO.read("/tmp/sp_io4_#{Process.pid}.txt")
IO.foreach("/tmp/sp_io4_#{Process.pid}.txt") { |l| p l }
rw = IO.pipe
p rw.class
w = rw[1]
r = rw[0]
w.write("ping")
w.close
p r.read
r.close
File.write("/tmp/sp_io4_#{Process.pid}.txt", "hello")
p IO.copy_stream("/tmp/sp_io4_#{Process.pid}.txt", "/tmp/sp_io4b_#{Process.pid}.txt")
p File.read("/tmp/sp_io4b_#{Process.pid}.txt")
fd = IO.sysopen("/tmp/sp_io4_#{Process.pid}.txt")
p fd.class
open("/tmp/sp_io4_#{Process.pid}.txt") { |f| p f.read }
File.open("/tmp/sp_io4_#{Process.pid}.txt") do |f|
  b001 = +""
  f.read(5, b001)
  p b001
end
File.open("/tmp/sp_io4_#{Process.pid}.txt", "w") { |f| f.puts([1, 2, 3]) }
p File.read("/tmp/sp_io4_#{Process.pid}.txt")
File.write("/tmp/sp_io4_#{Process.pid}.txt", "foo\nbar\n")
p File.readlines("/tmp/sp_io4_#{Process.pid}.txt", "o")
File.open("/tmp/sp_io4_#{Process.pid}.txt") { |f| p f.readlines("o") }
File.open("/tmp/sp_io4_#{Process.pid}.txt") { |f| p f.readlines(chomp: true) }
File.delete("/tmp/sp_io4_#{Process.pid}.txt", "/tmp/sp_io4b_#{Process.pid}.txt")
