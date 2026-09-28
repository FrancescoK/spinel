# File.readlines answers a line longer than 4095 bytes whole, with and
# without chomp:, as CRuby does, where it split it into 4095-byte pieces;
# a line holding a NUL comes back whole too, where it was cut at the NUL.
path = "/tmp/spinel_readlines_long_#{Process.pid}"
File.write(path, "A" * 8190 + "\nb\n" + "C" * 5000 + "\r\n")
p File.readlines(path).map(&:size)
p File.readlines(path, chomp: true).map(&:size)
p File.readlines(path)[1]
File.write(path, "a\0b\n\0\n")
p File.readlines(path)
p File.readlines(path, chomp: true)
File.delete(path)
