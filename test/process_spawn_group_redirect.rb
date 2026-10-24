# spinel: gc-stress
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_spawn_group_redirect_#{Process.pid}")
begin
  File.write(path, "old\n")
  pid = Process.spawn("/bin/sh", "-c", "echo O; echo E 1>&2", [:out, :err] => path)
  Process.waitpid2(pid)
  p File.read(path).lines.sort
  # the two slots share one file offset: each line lands whole, in order
  pid = Process.spawn("/bin/sh", "-c", "echo one; echo two 1>&2; echo three", [:err, :out] => path)
  Process.waitpid2(pid)
  p File.read(path)
ensure
  File.delete(path) if File.exist?(path)
end
