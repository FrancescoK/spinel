# Pathname.new("").mkpath raises Errno::ENOENT, as CRuby does, where it
# answered the Pathname; a real path is still made.
require "pathname"
p (Pathname.new("").mkpath rescue [$!.class, $!.message])
dir = "/tmp/spinel_mkpath_#{Process.pid}/a/b"
p Pathname.new(dir).mkpath.to_s == dir
p File.directory?(dir)
Dir.rmdir(dir)
Dir.rmdir(File.dirname(dir))
Dir.rmdir(File.dirname(File.dirname(dir)))
