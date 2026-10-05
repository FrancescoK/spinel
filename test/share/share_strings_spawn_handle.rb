# Flag-only: without the flag (as on master) spawn raises TypeError on the shared String.
# A String the rule shares is a String argument to spawn, and a
# redirect's path.
require "tmpdir"
path = File.join(Dir.tmpdir, "sp_share_spawn_#{Process.pid}.txt")
cmd = +"echo"; c2 = cmd; c2 << ""
arg = +"hi"; a2 = arg; a2 << "!"
pid = Process.spawn(cmd, arg, out: path)
Process.wait(pid)
p File.read(path)
pid = Process.spawn(cmd, a2 + "?", out: path)
Process.wait(pid)
p File.read(path)
File.delete(path)
