# spinel: gc-stress
# IO#gets and IO#readline with a limit of 0 answer "" without reading, and a
# nil limit after the separator is no limit.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_gets_zero_#{Process.pid}.txt")
File.write(path, "a\n\nb\n")
f = File.open(path)
p [f.gets(0), f.pos, f.lineno]
f.rewind
p [f.readline(0), f.pos, f.lineno]
p [f.gets("\n", 0), f.pos]
p [f.gets(nil, 0), f.pos]
p [f.gets("", 0), f.pos]
p [f.gets(0, chomp: true), f.pos]
p [f.gets(1), f.pos]
p [f.gets(-1), f.pos]
p [f.gets("\n", nil), f.pos]
n = 0
p [f.gets(n), f.pos]
x = [0, "b"][0]
p [f.gets(x), f.pos]
def rdsep(io, s, n) = io.readline(s, n)
f.rewind
p [rdsep(f, "\n", 0), rdsep(f, "\n", nil), f.pos]
# a lone Integer that may be nil: nil is the separator, which reads to the end
n = f.pos > 100 ? 1 : nil
z = f.pos > 100 ? 1 : 0
f.rewind
p [f.gets(z), f.gets(n), f.pos]
f.rewind
p [f.readline(n, chomp: true), f.pos]
f.rewind
p [[f, 1][0].gets(n), f.pos]
h = [f, 1][0]
f.rewind
p [h.gets(0), h.readline(0), f.pos]
p [h.gets("\n", nil), f.pos]
p f.read
p [f.gets(0), f.eof?]
p f.readline(0)
begin
  f.readline(1)
rescue EOFError => e
  p e.class
end
f.close
begin
  f.gets(0)
rescue IOError => e
  p [e.class, e.message]
end
File.delete(path)

# the same through a splat on a boxed IO, whose arguments are read at run
# time; the empty String keeps a binary stream's encoding
class Reader
  def gets(*args) = [:reader, args]
end
def read_data(io, name, *args) = io.__send__(name, *args)
r, w = IO.pipe
r.binmode
w.write("cd\n")
w.close
ios = [r, Reader.new]
t = read_data(ios[0], :gets, 0)
p [t, t.encoding, read_data(ios[0], :gets, "\n", 1), read_data(ios[1], :gets, 0)]
r.close
begin
  read_data(ios[0], :gets, 0)
rescue IOError => e
  p [e.class, e.message]
end
