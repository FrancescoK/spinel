# spinel: gc-stress
# spinel: share
require "tmpdir"
d = File.join(Dir.tmpdir, "spinel_dir_foreach_#{Process.pid}")
Dir.mkdir(d)
File.write(File.join(d, "a"), "")
e = Dir.foreach(d)
p e.class, e.size
p e.to_a.sort
p e.inspect.sub(d, "D")
p Dir.foreach(d, encoding: "BINARY").map(&:encoding).uniq
p Dir.foreach(d, encoding: Encoding::BINARY).inspect.sub(d, "D")
p Dir.foreach(d, encoding: 1).inspect.sub(d, "D")
p Dir.foreach(d).first(1).size
begin
  missing = Dir.foreach(File.join(d, "nope"))
  missing.first
rescue SystemCallError => x
  p x.class
end
File.delete(File.join(d, "a"))
Dir.rmdir(d)
