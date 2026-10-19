# File.read with an option other than an encoding Spinel reads as is
# refused, where the options hash reached the length slot and the C did
# not compile.
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_read_opts_#{Process.pid}")
File.write(path, "abc")
p File.read(path, mode: "rb")
