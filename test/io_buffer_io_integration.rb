# IO::Buffer's IO integration (#4474, makenowjust): read / write / pread /
# pwrite against an IO handle, one syscall each answering the byte count (0
# at EOF, -errno on failure), coordinated with the handle's stdio buffer
# (a read serves what the stream already holds first, a write flushes
# pending output first), parking the green thread on a socket or pipe that
# is not ready, with the buffer locked for the duration; and IO::Buffer.map
# as an mmap view of a file.
require 'socket'
path = "/tmp/sp_iob_#{Process.pid}.bin"
File.binwrite(path, "hello world, this is a file of bytes\n")

File.open(path, "rb") do |f|
  b = IO::Buffer.new(16)
  p b.read(f, 5)
  p b.get_string(0, 5)
  p b.read(f, 6, 5)
  p b.get_string(0, 11)
  p b.read(f)             # nil length: the rest of the buffer
  p b.get_string
  p b.read(f, 16)
  p b.read(f, 16)         # EOF
  p f.pos
end
File.open(path, "rb") do |f|
  b = IO::Buffer.new(8)
  p b.pread(f, 6, 5)
  p b.get_string(0, 5)
  p b.pread(f, 1000, 5)   # past the end: 0
  p f.pos                 # pread leaves the position alone
end

File.open(path, "wb") do |f|
  b = IO::Buffer.for("ABCDEFGH")
  p b.write(f, 4)
  p b.write(f, 2, 6)
  f.print "!"             # buffered in the stream...
  p b.pwrite(f, 0, 2, 1)  # ...and flushed ahead of the raw write
end
p File.binread(path)

# the stream's own buffer is served before the descriptor is read
File.open(path, "rb") do |f|
  p f.getc
  b = IO::Buffer.new(4)
  p b.read(f, 4)
  p b.get_string
  p f.read
end

# a pipe: the reader parks until the writer writes, and main collects
# meanwhile; EOF answers 0
r, w = IO.pipe
t = Thread.new do
  b = IO::Buffer.new(32)
  n = b.read(r, 32)
  [n, b.get_string(0, n), b.locked?]
end
sleep 0.05
GC.start
w.write("pipe bytes")
p t.value
w.close
p IO::Buffer.new(8).read(r, 8)

# a thread killed while parked in a read leaves the buffer unlocked
r2, w2 = IO.pipe
kb = IO::Buffer.new(8)
tk = Thread.new { kb.read(r2, 8) }
sleep 0.05
p kb.locked?
tk.kill
tk.join
p kb.locked?
kb.resize(4)
p kb.size

# a socket pair, both directions
s1, s2 = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
out = IO::Buffer.for("sock!")
p out.write(s1, 5)
inb = IO::Buffer.new(16)
p inb.read(s2, 5)
p inb.get_string(0, 5)

# the checks: a readonly buffer is not read into, a closed stream, a
# non-IO, a range past the buffer
ro = IO::Buffer.for("x")
begin
  ro.read(r, 1)
rescue IO::Buffer::AccessError => e
  p e.message
end
begin
  IO::Buffer.new(4).read(42, 4)
rescue TypeError => e
  p e.message
end
begin
  IO::Buffer.new(4).read(r, 8)
rescue ArgumentError => e
  p e.message
end
begin
  File.open(path) { |f| f.close; IO::Buffer.new(4).read(f, 4) }
rescue IOError => e
  p e.message
end

# map: a readonly view, a view at an offset, a slice of a view, a shared
# writable view that writes through, a private one that does not
File.binwrite(path, "mapped file contents")
File.open(path, "rb") do |f|
  m = IO::Buffer.map(f, nil, 0, IO::Buffer::READONLY)
  p m.size, m.mapped?, m.readonly?, m.shared?
  p m.get_string(0, 6)
  begin
    m.set_string("X")
  rescue IO::Buffer::AccessError => e
    p e.message
  end
  begin
    m.resize(100)
  rescue IO::Buffer::AccessError => e
    p e.message
  end
  p IO::Buffer.map(f, 4, 7, IO::Buffer::READONLY).get_string
  p m.slice(7, 4).get_string
  p m.get_value(:U8, 0)
end
File.open(path, "r+b") do |f|
  m = IO::Buffer.map(f, nil, 0, 0)
  p m.readonly?, m.shared?
  m.set_string("MAPPED")
end
p File.binread(path)
File.open(path, "r+b") do |f|
  m = IO::Buffer.map(f, nil, 0, IO::Buffer::PRIVATE)
  p m.private?, m.shared?
  m.set_string("private")
  p m.get_string(0, 7)
  p m.free.null?
end
p File.binread(path)
File.delete(path)
