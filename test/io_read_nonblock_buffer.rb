# Nonblocking reads fill a captured output buffer, clear it at EOF, and
# leave it alone on would-block. The exception keyword may be a value.
r, w = IO.pipe
buf = +"seed"
read_buffer = -> { buf }
p r.read_nonblock(3, buf, exception: false), read_buffer.call
begin
  r.read_nonblock(3, buf)
rescue IO::WaitReadable
  p :wait
end
p read_buffer.call
w.write("a\0b")
p r.read_nonblock(3, buf), read_buffer.call
w.write("xy")
exc = false
p r.read_nonblock(2, buf, exception: exc), read_buffer.call
p r.read_nonblock(2, buf, exception: exc), read_buffer.call
p r.read_nonblock(0, buf), read_buffer.call
w.close
buf = +"seed"
begin
  r.read_nonblock(3, buf, exception: nil)
rescue ArgumentError
  p :exception_type
end
p r.read_nonblock(3, buf, exception: false), read_buffer.call
buf = +"seed"
begin
  r.read_nonblock(3, buf, exception: true)
rescue EOFError
  p :eof
end
p read_buffer.call
begin
  r.read_nonblock(-1, buf)
rescue ArgumentError
  p :negative
end
begin
  r.read_nonblock(1, 3)
rescue TypeError
  p :buffer_type
end
begin
  r.read_nonblock(1, "frozen")
rescue FrozenError
  p :frozen
end
p r.read_nonblock(1, nil, exception: false)
r.close

# The length runs before the buffer is captured, and the keyword after it.
def read_length(log)
  log << :length
  1
end
r, w = IO.pipe
w.write("z")
w.close
buf = +"old"
log = []
p r.read_nonblock(read_length(log), buf, exception: (log << :keyword; buf = +"new"; false))
p buf, log
r.close
