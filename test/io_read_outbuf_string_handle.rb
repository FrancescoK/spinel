# The (len, outbuf) form of readpartial / sysread rebinds a plain local to
# the bytes read. A buffer the program also appends to is a mutable String
# handle, and assigning the bytes to the handle did not compile (#7314): its
# contents are replaced instead. read_nonblock took the buffer argument and
# left the buffer as it was.
r, w = IO.pipe
w.write("hello world, more bytes here, and then some")
w.close

buf = String.new(capacity: 16)
r.readpartial(4, buf)
buf << r.readpartial(4) while buf.bytesize < 7
p buf

b1 = +""
r.sysread(3, b1)
b1 << "!"
p b1

b2 = +"old"
r.read(4, b2)
b2 << "+"
p b2

b3 = +""
r.read_nonblock(3, b3)
b3 << "?"
p b3

b4 = +"plain"
r.read_nonblock(2, b4)
p b4

b5 = +"keep"
p r.read_nonblock(3, b5, exception: false)
b5 << "."
p b5

fz = "frozen"
begin
  r.readpartial(2, fz)
rescue FrozenError => e
  puts "FrozenError"
end
begin
  r.read_nonblock(2, fz)
rescue FrozenError => e
  puts "FrozenError"
end
p r.read(5)
