# Blocking reads answer the caller's buffer itself, for typed and boxed
# streams and buffers. Mutating either name must reach the other name.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_io_buffer_return_#{Process.pid}")
File.write(path, "abcde")
f = File.open(path)
b = +"old"
r = f.read(2, b)
r << "!"
p [b, r]
b << "?"
p r
r = f.pread(2, 2, b)
r << "+"
p [b, r]
f.rewind
r = f.sysread(1, b)
r << "s"
p b
r = f.readpartial(1, b)
r << "p"
p b

h = [f, 1][ARGV.length]
buf = [+"old", 1][ARGV.length]
r = h.readpartial(1, buf)
r << "h"
p buf
r = h.pread(1, 0, buf)
r << "b"
p buf
r = h.read(1, buf)
r << "r"
p buf

# A fresh or nil buffer has no borrowed identity to retain.
r = f.pread(2, 0, +"fresh")
r << "+"
p r
r = f.pread(2, 0, nil)
r << "n"
p r

# Evaluate all operands once, before dispatch; preserve the supplied
# buffer when evaluating an earlier operand rebinds another name.
$events = +""
def length_arg
  $events << "l"
  1
end
def offset_arg
  $events << "o"
  0
end
def buffer_arg(b)
  $events << "b"
  b
end
r = f.pread(length_arg, offset_arg, buffer_arg(b))
r << "x"
p [$events, b]
# An outbuf read from a retained container must keep that element's identity.
ary = [+"old", 1]
r = f.pread(1, 0, ary[ARGV.length])
r << "a"
p ary
f.close
File.delete(path)
