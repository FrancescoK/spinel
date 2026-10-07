# Flag-only: without --share-strings the String an IO read answers is a
# String of its own, not the buffer it filled (the default build keeps
# Strings by value).
# An IO read into an output buffer answers the buffer itself, as CRuby
# does: read, readpartial, sysread, read_nonblock and pread, the answer
# changed in place changes the buffer and its aliases, and at the end of
# the file read answers nil and leaves the buffer empty. A buffer a lambda
# captures answers itself the same way.
require "tmpdir"

PATH = File.join(Dir.tmpdir, "spinel_io_read_answers_#{Process.pid}.txt")
File.write(PATH, "0123456789")

def answers
  f = File.open(PATH)
  buf = +"ab"
  u = buf
  r = f.read(3, buf)
  p r.equal?(buf)
  r << "X"
  p buf, u
  r = f.readpartial(2, buf)
  r << "Y"
  p buf, u
  r = f.sysread(2, buf)
  r << "Z"
  p buf, u
  r = f.read_nonblock(2, buf)
  r << "W"
  p buf, u
  r = f.pread(2, 0, buf)
  r << "V"
  p buf, u
  r = f.read(9, buf)
  p r, buf, u
  r = f.read(9, buf)
  p r, buf, u
  f.close
end

def captured
  f = File.open(PATH)
  buf = +"ab"
  g = -> { buf }
  r = f.read(4, buf)
  r << "!"
  p g.call
  f.read(4, buf) << "?"
  p g.call
  f.close
end

answers
captured
File.delete(PATH)
