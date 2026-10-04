# A Dir read out of a container names its class and inspects as a typed Dir
# does: #<Dir:PATH>, class Dir, and a NoMethodError message naming Dir.
# The Dir is made in a scratch directory of this process's own, so that two
# runs at once do not share it, and named relative to it.
scratch = "/tmp/sp_boxed_dir_inspect_#{Process.pid}"
Dir.mkdir(scratch) unless Dir.exist?(scratch)
Dir.chdir(scratch)
path = "sp_boxed_dir_inspect"
Dir.mkdir(path) unless Dir.exist?(path)
h = Dir.open(path)
d = [h, 0][0]
p d
p d.inspect
p d.class
puts d.class.name
p [d, 1]
p({ dir: d })
e = (d.no_such_method rescue $!)
p e.message
h.close
Dir.rmdir(path)
Dir.chdir("/")
Dir.rmdir(scratch)
