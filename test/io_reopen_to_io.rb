# IO#reopen takes an object that answers #to_io, which CRuby asks before it
# reads the argument as a path, and a box that holds one or holds an IO.
# Both were refused, read as a path. And $stdout, once a StringIO was put
# there too, reopens as the IO it is: that raised NoMethodError.
require "stringio"
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_io_reopen_to_io_#{Process.pid}")
f = File.open(path, "w+")

class Sink
  def initialize(io) = @io = io
  def to_io = @io
end

saved = $stdout.dup
p saved.equal?($stdout)
p saved.fileno == $stdout.fileno
$stdout.reopen(Sink.new(f))
puts "into the file"
$stdout.flush
$stdout.reopen(saved)
puts "back on stdout"
f.rewind
p f.read

# a box that holds the wrapper, and one that holds a File
saved_err = $stderr.dup
box = [Sink.new(f), "x"].first
$stderr.reopen(box)
$stderr.puts "via the box"
$stderr.flush
$stderr.reopen(saved_err)
other = [f, 1].first
$stderr.reopen(other)
$stderr.puts "via a boxed File"
$stderr.flush
$stderr.reopen(saved_err)
f.rewind
p f.read

# $stdout may also hold a StringIO
def capture(f)
  saved = STDOUT.dup
  $stdout.reopen(f)
  yield
  $stdout.flush
ensure
  $stdout.reopen(saved)
  saved.close
end
f.rewind
f.truncate(0)
capture(Sink.new(f).to_io) { puts "reopened" }
sio = StringIO.new
$stdout = sio
puts "into the StringIO"
$stdout = STDOUT
f.rewind
p f.read, sio.string

# an Object answers neither #to_io nor #to_path
begin
  $stdout.reopen(Object.new)
rescue TypeError => e
  p e.class
end

saved.close
saved_err.close
f.close
File.delete(path)
