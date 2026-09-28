# IO#read(nil) is read with no length: the rest of the stream, as CRuby
# does, where the nil was converted to an Integer and raised TypeError.
path = "/tmp/spinel_read_nil_#{Process.pid}"
File.write(path, "abcdef")
f = File.open(path)
p f.read(2)
p f.read(nil)
p f.read(nil)
f.close
n = nil
File.open(path) { |g| p g.read(n) }
# a length that may be nil or an Integer at run time
[nil, 3].each do |len|
  File.open(path) { |g| p g.read(len) }
end
r, w = IO.pipe
w.write("xyz")
w.close
p r.read(nil)
r.close
File.delete(path)
