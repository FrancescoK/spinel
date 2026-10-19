# IO::Buffer.map with no flags argument maps the file writable and shared,
# as CRuby does (flags default 0): writes go through to the file, and a
# file opened read-only is refused by mmap unless READONLY is passed.
require 'tmpdir'
path = File.join(Dir.tmpdir, "sp_iob_map_default_#{Process.pid}.bin")
File.binwrite(path, "abcdefgh")

File.open(path, "r+b") do |f|
  b = IO::Buffer.map(f, 8, 0)
  p b.readonly?, b.shared?
  b.set_value(:U8, 0, 65)
  m = IO::Buffer.map(f)
  p m.size, m.readonly?
  m.set_string("B", 1)
end
p File.binread(path)

File.open(path, "rb") do |f|
  begin
    IO::Buffer.map(f, 8, 0)
    puts "mapped"
  rescue Errno::EACCES => e
    p e.class
  end
  b = IO::Buffer.map(f, 8, 0, IO::Buffer::READONLY)
  p b.readonly?, b.get_string
end
File.delete(path)
