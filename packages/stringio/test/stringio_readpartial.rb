# StringIO#readpartial, #sysread and #read_nonblock: read(n), but EOFError
# at the end (read_nonblock answers nil there with exception: false).
require "stringio"

s = StringIO.new("hello world")
p s.readpartial(5)
p s.readpartial(100)
begin
  s.readpartial(3)
rescue EOFError => e
  p [e.class, e.message]
end

p StringIO.new("ab").readpartial(0)
p StringIO.new("").readpartial(0)
begin
  StringIO.new("ab").readpartial(-1)
rescue ArgumentError => e
  p e.message
end

buf = +"old"
p StringIO.new("abc").readpartial(2, buf)
p buf

p StringIO.new("q").sysread(5)
begin
  StringIO.new("").sysread(1)
rescue EOFError => e
  p e.class
end

p StringIO.new("r").read_nonblock(5)
begin
  StringIO.new("").read_nonblock(1)
rescue EOFError => e
  p e.class
end
p StringIO.new("").read_nonblock(1, exception: false)

# the rescue-modifier form a server loop uses
io = StringIO.new("chunk")
a = io.readpartial(16384) rescue nil
b = io.readpartial(16384) rescue nil
p [a, b]

# read(n) answers nil at the end, read(0) and read answer ""
r = StringIO.new("ab")
p r.read(5)
p r.read(5)
p r.read(0)
p r.read
