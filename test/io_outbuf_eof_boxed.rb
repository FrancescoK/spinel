# At the end of the stream CRuby empties the output buffer before it raises:
# readpartial, sysread and pread leave the buffer "" and raise EOFError, and
# read(n, buf) leaves it "" and answers nil. A buffer that is not a String at
# compile time (boxed, or nil) went through a path that raised before the
# buffer was emptied, so it kept its old bytes. The buffer is also filled by a
# read that stops short, a nil buffer is no buffer at all, and an error raised
# before the read (a closed stream, a negative length) leaves it alone. The
# handle is typed, and for readpartial also a stream read back out of an array.
require "tmpdir"

def t
  r = yield
  p [:ret, r]
rescue EOFError, IOError, ArgumentError => e
  p [:raise, e.class]
end

path = File.join(Dir.tmpdir, "spinel_io_outbuf_eof_#{Process.pid}.txt")
File.write(path, "abcde")
k = ARGV.size
f = File.open(path)

# a read that stops short fills the buffer; the one after it is at the end
b = [+"old", 1][k]
t { f.readpartial(3, b) }
p b
t { f.sysread(9, b) }
p b
t { f.readpartial(2, b) }
p b
t { f.sysread(2, b) }
p b

b = [+"old", 1][k]
t { f.pread(2, 1, b) }
p b
t { f.pread(2, 5, b) }
p b
t { f.pread(2, 99, b) }
p b

b = [+"old", 1][k]
t { f.read(2, b) }
p b
b = [+"old", 1][k]
t { f.read(nil, b) }
p b

f.rewind
b = [+"old", 1][k]
t { f.read(2, b) }
p b
t { f.read(9, b) }
p b
b = [+"old", 1][k]
t { f.read(2, b) }
p b
b = [+"old", 1][k]
t { f.read(0, b) }
p b

# the buffer is appended to after the read
b = [+"old", 1][k]
t { f.pread(2, 77, b) }
b << "+"
p b

# nil is no buffer: nothing to empty, and the same answers
n = [nil, 1][k]
t { f.readpartial(2, n) }
t { f.sysread(2, n) }
t { f.pread(2, 77, n) }
t { f.read(2, n) }
f.rewind
t { f.readpartial(2, n) }
t { f.pread(2, 3, n) }

# nothing is emptied when the read never starts
b = [+"old", 1][k]
neg = -1
t { f.readpartial(neg, b) }
p b
t { f.read(neg, b) }
p b
f.close
t { f.readpartial(2, b) }
t { f.sysread(2, b) }
t { f.pread(2, 0, b) }
t { f.read(2, b) }
p b

# the stream read back out of an array
File.open(path) do |g|
  h = [g, 1][k]
  b = [+"old", 1][k]
  t { h.readpartial(9, b) }
  p b
  b = [+"old", 1][k]
  t { h.readpartial(9, b) }
  p b
end
File.delete(path)
