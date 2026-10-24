# spinel: gc-stress
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel-boxed-dir-state-#{Process.pid}")
Dir.mkdir(path)
File.write(File.join(path, "a"), "")
d = Dir.open(path)
x = [d, 0][0]
begin
  p x.count
  p x.count
  p x.include?("a")
  p x.include?("missing")
  p x.include?(1)
  p x.include?(".")
ensure
  d.close
  File.delete(File.join(path, "a"))
  Dir.rmdir(path)
end
begin
  x.count
rescue IOError => e
  p e.message
end
begin
  x.include?("a")
rescue IOError => e
  p e.message
end
