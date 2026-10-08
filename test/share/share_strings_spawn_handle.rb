# Flag-only: a String the program holds as the shared handle reaches
# Process.spawn and exec boxed as the handle, which the spawn took for no
# String ("spawn args must be Strings"): `spin clean`'s
# `run_command("rm -rf #{...}")` under --share-strings. It reads the
# handle's bytes now, as it reads a String's.
def run(cmd)
  pid = Process.spawn("sh", "-c", cmd)
  _, st = Process.waitpid2(pid)
  st.success?
end
seen = []
dir = "build"
c = "echo spawned #{dir}"
seen << c
c << " now"
p run(c), seen
pid = Process.spawn(c)
Process.waitpid2(pid)
arg = +"plain"
keep = [arg]
arg << " arg"
pid = Process.spawn("echo", arg)
Process.waitpid2(pid)
p keep

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
