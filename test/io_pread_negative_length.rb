# spinel: gc-stress
# IO#pread(length, offset) with a negative length raises ArgumentError, also
# on a closed handle (the length is checked first) and through a value that
# may be a File or nil, on a pipe and on a write-only File.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_pread_negative_#{Process.pid}.txt")
File.write(path, "abc")
f = File.open(path)
begin
  p f.pread(-1, 0)
rescue => e
  p [e.class, e.message]
end
p f.pread(0, 0)
p f.pread(2, 1)
g = [f, nil][Process.pid % 1]
begin
  p g.pread(-2, 0)
rescue => e
  p [e.class, e.message]
end
f.close
begin
  f.pread(-1, 0)
rescue => e
  p [e.class, e.message]
end
r, wr = IO.pipe
[r, wr, File.open(path, "a")].each do |io|
  begin
    io.pread(-1, 0)
  rescue => e
    p [e.class, e.message]
  end
end
File.delete(path)
