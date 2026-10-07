# An IO read into an output buffer empties the buffer at the end of the
# file, as CRuby does: read(n, buf) and read_nonblock(n, buf, exception:
# false) then answer nil, readpartial, read_nonblock and pread raise
# EOFError after emptying it, and read(nil, buf) answers "". The buffer
# kept the last bytes read, or became nil, and a boxed receiver did not
# rebind it at all. Each form runs on a typed and on a boxed receiver, with
# the buffer a plain local and one a lambda captures; a closed stream
# still leaves the buffer as it was.
require "tmpdir"

PATH = File.join(Dir.tmpdir, "spinel_io_buffer_eof_#{Process.pid}.txt")
File.write(PATH, "0123456789")

def eof?
  yield
rescue EOFError => e
  p e.class
end

def open_io(boxed)
  boxed ? [File.open(PATH), 1][0] : File.open(PATH)
end

def plain_buffer(boxed)
  f = open_io(boxed)
  buf = +"zz"
  r = f.read(4, buf)
  p r, buf
  r = f.read(40, buf)
  p r, buf
  r = f.read(4, buf)
  p r, buf
  f.close
  f = open_io(boxed)
  buf = +"zz"
  r = f.read_nonblock(40, buf, exception: false)
  p r, buf
  r = f.read_nonblock(4, buf, exception: false)
  p r, buf
  eof? { f.read_nonblock(4, buf) }
  p buf
  f.close
  f = open_io(boxed)
  buf = +"zz"
  r = f.readpartial(4, buf)
  p r, buf
  n = 0
  while (f.readpartial(3, buf) rescue nil)
    n += 1
  end
  p n, buf
  buf = +"zz"
  r = f.pread(4, 3, buf)
  p r, buf
  eof? { f.pread(4, 20, buf) }
  p buf
  f.close
end

def captured_buffer(boxed)
  buf = +"zz"
  g = -> { buf }
  f = open_io(boxed)
  r = f.read(40, buf)
  p r, g.call
  r = f.read(4, buf)
  p r, g.call
  buf << "!"
  r = f.read_nonblock(4, buf, exception: false)
  p r, g.call
  buf << "!"
  eof? { f.read_nonblock(4, buf) }
  buf << "!"
  eof? { f.readpartial(4, buf) }
  buf << "!"
  eof? { f.pread(4, 20, buf) }
  p g.call
  f.close
end

def read_nil
  File.open(PATH) do |f|
    buf = +"zz"
    g = -> { buf }
    r = f.read(nil, buf)
    p r, g.call
    r = f.read(nil, buf)
    p r, g.call
  end
end

def closed_stream
  buf = +"zz"
  f = File.open(PATH)
  f.close
  begin
    f.readpartial(4, buf)
  rescue IOError => e
    p e.class
  end
  p buf
end

plain_buffer(false)
plain_buffer(true)
captured_buffer(false)
captured_buffer(true)
read_nil
closed_stream
File.delete(PATH)
