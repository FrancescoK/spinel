# spinel: gc-stress
require "tmpdir"
# Dir.mkdir(path, mode) creates the directory with the requested
# permissions, filtered by the process umask; Dir.mkdir(path) uses 0777.
base = File.join(Dir.tmpdir, "sp_dir_mkdir_mode_#{Process.pid}")
mask = File.umask(0o022)
begin
  [0o700, 0o750, 0o711, 0o777].each do |mode|
    Dir.mkdir(base, mode)
    p sprintf("%o", File.stat(base).mode & 0o777)
    Dir.rmdir(base)
  end
  Dir.mkdir(base)
  p sprintf("%o", File.stat(base).mode & 0o777)
  Dir.rmdir(base)
  File.umask(0o027)
  Dir.mkdir(base, 0o777)
  p sprintf("%o", File.stat(base).mode & 0o777)
ensure
  Dir.rmdir(base) if Dir.exist?(base)
  File.umask(mask)
end
