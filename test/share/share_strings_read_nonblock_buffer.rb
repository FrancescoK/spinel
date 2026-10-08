# The result carries the supplied handle through typed and boxed IO calls.
# Capturing the buffer before a keyword rebinds its variable keeps the
# original String as both the output buffer and the returned value.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_nonblock_buffer_#{Process.pid}")
File.write(path, "a\0bcdef")
File.open(path) do |f|
  buf = +"old"
  captured = -> { buf }
  result = f.read_nonblock(3, buf)
  result << "!"
  p buf, result.equal?(buf), captured.call
  original = buf
  result = f.read_nonblock(2, buf, exception: (buf = +"new"; false))
  p result, original, buf, result.equal?(original)
  result << "?"
  p original, captured.call
end
f = [File.open(path), 1][ARGV.size]
source = +"boxed"
buf = [source, 1][ARGV.size]
result = f.read_nonblock(3, buf, exception: false)
result << "!"
p source, buf, result.equal?(buf)
f.read
p f.read_nonblock(2, buf, exception: false), source
f.close
r, w = IO.pipe
buf = +"waiting"
alias_buf = buf
p r.read_nonblock(1, buf, exception: false), alias_buf
w.close
begin
  r.read_nonblock(1, buf)
rescue EOFError
  p :eof
end
p alias_buf
r.close
File.delete(path)
