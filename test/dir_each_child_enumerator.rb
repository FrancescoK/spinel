# spinel: gc-stress
require "tmpdir"
d = File.join(Dir.tmpdir, "spinel_dir_each_child_#{Process.pid}")
Dir.mkdir(d)
File.write(File.join(d, "a"), "")
File.write(File.join(d, ".h"), "")
e = Dir.each_child(d)
p e.class, e.size
p e.to_a.sort
p e.next.class
e.rewind
p e.to_a.sort
p e.inspect.sub(d, "D")
p Dir.each_child(d, encoding: "BINARY").map(&:encoding).uniq
p Dir.each_child(d, encoding: Encoding::BINARY).inspect.sub(d, "D")
p Dir.each_child(d).with_index.map { |n, i| i }.sort
p Dir.each_child(d).first(1).size
p Dir.children(d).sort
p(Dir.each_child(d) { }.class)
File.delete(File.join(d, "a"))
File.delete(File.join(d, ".h"))
p Dir.each_child(d).to_a
begin
  missing = Dir.each_child(File.join(d, "nope"))
  missing.first
rescue SystemCallError => x
  p x.class
end
Dir.rmdir(d)
