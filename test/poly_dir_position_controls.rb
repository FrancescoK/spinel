# spinel: gc-stress
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel-boxed-dir-controls-#{Process.pid}")
Dir.mkdir(path)
d = Dir.open(path)
x = [d, 0][0]
begin
  first = x.read
  p first.class
  p x.rewind.equal?(d)
  p x.read == first
  at = x.tell
  second = x.read
  p x.seek(at).equal?(d)
  p x.read == second
  p x.rewind.class
  p x.read == first
ensure
  d.close
  Dir.rmdir(path)
end
file = File.join(Dir.tmpdir, "spinel-boxed-io-seek-#{Process.pid}.txt")
File.write(file, "abc")
f = [File.open(file), 0][0]
begin
  p f.seek(1)
  p f.read
  p f.rewind
  p f.read
ensure
  f.close
  File.delete(file)
end
