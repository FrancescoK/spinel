# spinel: gc-stress
require "pathname"
require "tmpdir"
# Pathname#mkdir(mode) forwards the mode to Dir.mkdir; with no argument
# the directory gets 0777 filtered by the process umask.
path = File.join(Dir.tmpdir, "spinel_pathname_mkdir_mode_#{Process.pid}")
pn = Pathname.new(path)
mask = File.umask(0o022)
begin
  [0o700, 0o750].each do |mode|
    p pn.mkdir(mode)
    p sprintf("%o", File.stat(path).mode & 0o777)
    pn.rmdir
  end
  pn.mkdir
  p sprintf("%o", File.stat(path).mode & 0o777)
ensure
  Dir.rmdir(path) if Dir.exist?(path)
  File.umask(mask)
end
