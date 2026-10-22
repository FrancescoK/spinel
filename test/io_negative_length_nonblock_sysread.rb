# A negative length is an ArgumentError ahead of the stream for
# read_nonblock (also with `exception: false` and on a boxed IO, where it
# answered "") and for sysread (where it raised EOFError), each in CRuby's
# words.
def try
  p yield
rescue => e
  p [e.class, e.message]
end

r, w = IO.pipe
w.write("ab")
try { r.read_nonblock(-1) }
try { r.read_nonblock(-1, exception: false) }
try { r.read_nonblock(-2, +"x") }
try { r.sysread(-1) }
io = [r, 1][0]
try { io.read_nonblock(-3) }
try { io.read_nonblock(-3, exception: false) }
try { r.read_nonblock(1) }
try { r.sysread(1) }
w.close
try { r.read_nonblock(-4) }
r.close
try { r.read_nonblock(-5) }
try { r.sysread(-6) }
