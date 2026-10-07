# readpartial, sysread and read_nonblock into a String handle (a buffer that
# is also appended to) keep binary bytes past a NUL: the bytes read were
# stored by strlen, and a frame starting "\x01\x00" left one byte.
FRAME = "\x01\x00\x00\x00\x00\x00\x05hello\xCE".b

def pipe_with_frame
  r, w = IO.pipe
  w.write(FRAME)
  w.close
  r
end

buf = String.new(capacity: 64)
pipe_with_frame.readpartial(64, buf)
buf << "!"
p buf.bytesize
p buf.byteslice(0, 13) == FRAME

buf = String.new(capacity: 64)
pipe_with_frame.sysread(64, buf)
buf << "!"
p buf.bytesize
p buf.byteslice(0, 13) == FRAME

buf = String.new(capacity: 64)
pipe_with_frame.read_nonblock(64, buf)
buf << "!"
p buf.bytesize
p buf.byteslice(0, 13) == FRAME

r, w = IO.pipe
w.write("\x01\x00\x02\x03\x04\x05\x06\x07\x08".b)
w.close
head = String.new(capacity: 16)
r.readpartial(4, head)
head << r.readpartial(4) while head.bytesize < 7
p head.bytes
