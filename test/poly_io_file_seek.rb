# An ivar that holds a File in one writer and a StringIO in another:
# seek and read(n) on the File reached a dispatch built for StringIO's
# methods and raised NoMethodError. Uses a temp file it deletes.
require "stringio"
require "tmpdir"

class Patcher
  def initialize(io) = @io = io
  def put(s) = @io.write(s)

  def write_at(offset, bytes)
    @io.seek(offset)
    @io.write(bytes)
  end

  def read_from_end(n)
    @io.seek(-n, IO::SEEK_END)
    @io.read(n)
  end
end

path = File.join(Dir.tmpdir, "sp_poly_io_file_seek_#{Process.pid}.bin")
File.open(path, "w+b") do |f|
  w = Patcher.new(f)
  w.put("RIFFxxxxWAVE")
  w.write_at(4, "abcd")
  p w.read_from_end(4)
end
s = StringIO.new(+"")
w = Patcher.new(s)
w.put("RIFFxxxxWAVE")
w.write_at(4, "wxyz")
p w.read_from_end(4)
p File.binread(path)
p s.string
File.delete(path)
