# File.read and File.binread with an offset read from that byte, as CRuby
# does, where the call raised NoMethodError at run time.
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_read_offset_#{Process.pid}")
File.write(path, "0123456789")
p File.read(path, 4, 3)
p File.read(path, 4, 8)
p File.read(path, nil, 7)
p File.read(path, nil, 20)
p File.read(path, 0, 20)
data = File.binread(path, 3, 2)
p data, data.encoding
p (File.read(path, 2, -1) rescue [$!.class, $!.message])
p (File.read(path, -1, 0) rescue [$!.class, $!.message])
File.delete(path)
p (File.read(path, 1, 0) rescue $!.class)
