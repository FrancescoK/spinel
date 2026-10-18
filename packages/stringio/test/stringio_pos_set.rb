# StringIO#pos= moves the read position and answers it; past the end reads
# nothing, and a negative position raises Errno::EINVAL. `io.pos -= 1`
# reads and writes it through the pair.
require "stringio"

io = StringIO.new("abcdef".b)
p io.getbyte, io.getbyte
p(io.pos = 4)
p io.getbyte
io.pos -= 2
p io.pos, io.getbyte
io.pos += 1
p io.read
p(io.pos = 10)
p io.getbyte, io.eof?
begin
  io.pos = -1
rescue SystemCallError => e
  p e.class, e.message
end
p io.pos
