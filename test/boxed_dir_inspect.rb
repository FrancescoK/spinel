# A Dir read out of a container names its class and inspects as a typed Dir
# does: #<Dir:PATH>, class Dir, and a NoMethodError message naming Dir.
path = "/tmp/sp_boxed_dir_inspect"
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
