# A wrapper handing its arguments and its block on to a File's readers reads
# what the File reads. A `&block` reached each_line's loop with no body and
# nothing ran, a length that may be nil was a TypeError, and a splat was
# taken as one argument: read(*a) read the Array as the length, and
# gets(*a) did not compile.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_io_reader_forwards_#{Process.pid}")
File.write(path, "ab,cd\nef\ngh\n")

class Reader
  def initialize(f) = @f = f
  def each_line(&b) = @f.each_line(&b)
  def each_char(&b) = @f.each_char(&b)
  def each_byte(&b) = @f.each_byte(&b)
  def read(length = nil) = @f.read(length)
  def read_any(*args) = @f.read(*args)
  def gets(*args, **opts) = @f.gets(*args, **opts)
  def readline(*args, **opts) = @f.readline(*args, **opts)
  def readlines(*args, **opts) = @f.readlines(*args, **opts)
  def rewind = @f.rewind
end

f = File.open(path)
r = Reader.new(f)
r.each_line { |l| p l }
r.rewind
chars = []
r.each_char { |c| chars << c }
p chars.size
r.rewind
bytes = 0
r.each_byte { |b| bytes += b }
p bytes
r.rewind
r.each_line { |l| p l; break if l == "ef\n" }

# the length, nil or not
r.rewind
p r.read(2), r.read, r.read, r.read(1)
r.rewind
p r.read_any(3), r.read_any(nil), r.read_any
r.rewind
begin
  r.read_any(1, +"", 3)
rescue ArgumentError => e
  p e.message
end

# the line readers' separator, limit and chomp:
r.rewind
p r.gets, r.gets(chomp: true), r.gets(1), r.gets(0), r.gets(nil)
r.rewind
p r.gets(","), r.gets(",", 1), r.readline(chomp: true)
r.rewind
p r.readlines
r.rewind
p r.readlines(",", 3)
r.rewind
p r.readlines(chomp: true)
begin
  r.readlines(0)
rescue ArgumentError => e
  p e.message
end
begin
  r.readline
rescue EOFError => e
  p e.class
end
f.close

# a proc, a lambda and a Method handed to a File's own iterators
g = File.open(path)
seen = []
keep = proc { |l| seen << l }
g.each_line(&keep)
g.rewind
g.each_line(",", &keep)
p seen
g.rewind
up = ->(l) { print l.upcase }
g.each_line(&up)
def show(x) = p(x)
g.rewind
g.gets
g.each_char(&method(:show))
n = 0
g.rewind
g.each_byte(&proc { |b| n += 1 })
p n
g.close
File.delete(path)
