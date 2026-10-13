# File.foreach(path).first(n) reads only the lines it answers, as CRuby's
# lazy Enumerator does; the answers match on every edge.
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_foreach_first_#{Process.pid}.txt")
File.write(path, "a\nb\nc\n")
p File.foreach(path).first(2)
p File.foreach(path).first(10)
p File.foreach(path).first(0)
p IO.foreach(path).first(1)
begin
  File.foreach(path).first(-1)
rescue ArgumentError => e
  puts e.message
end
File.delete(path)
p File.foreach(path).first(0)
