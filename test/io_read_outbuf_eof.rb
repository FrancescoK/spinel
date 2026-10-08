# EOF clears each output buffer before returning nil or raising EOFError.
r, w = IO.pipe
w.close
buf = +"seed"
p r.read(4, buf)
p buf
r.close

r, w = IO.pipe
w.close
buf = +"seed"
begin
  r.readpartial(4, buf)
rescue EOFError
  p :eof
end
p buf
r.close

r, w = IO.pipe
w.close
buf = +"seed"
begin
  r.sysread(4, buf)
rescue EOFError
  p :eof
end
p buf
r.close

r, w = IO.pipe
w.close
buf = +"seed"
p r.read_nonblock(4, buf, exception: false)
p buf
r.close

# Positional reads and an existing mutable handle clear their buffers too.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_io_read_outbuf_eof_#{Process.pid}")
File.write(path, "")
File.open(path) do |f|
  buf = +"seed"
  begin
    f.pread(4, 0, buf)
  rescue EOFError
    p :eof
  end
  p buf
end
File.delete(path)

r, w = IO.pipe
w.close
buf = String.new("seed")
begin
  r.readpartial(4, buf)
rescue EOFError
  p :eof
end
buf << "!"
p buf
r.close

# A nil buffer stays nil; a keyword may replace the local after capture.
r, w = IO.pipe
w.write("xy")
w.close
buf = nil
p r.read_nonblock(1, buf, exception: false), buf
buf = +"seed"
p r.read_nonblock(1, buf, exception: (buf = nil; false)), buf
r.close

# A length conversion can collect after the fresh receiver was evaluated.
class OutbufReadLength
  def to_int
    30.times { String.new("temporary") }
    4
  end
end

def eof_reader
  r, w = IO.pipe
  w.close
  r
end

length = OutbufReadLength.new
buf = +"seed"
p eof_reader.read_nonblock(length, buf, exception: false), buf

# A nil Integer sentinel remains nil at the runtime length conversion.
r, w = IO.pipe
w.close
missing_length = [1][ARGV.size + 1]
buf = +"seed"
begin
  r.read_nonblock(missing_length, buf, exception: false)
rescue TypeError
  p :length_type
end
p buf
r.close
