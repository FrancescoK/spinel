# Dir.new/Dir.open handles: #read/#each/#each_child/#children/#entries/
# #path/#rewind/#close, the block form, and Errno::ENOENT on a missing path.
# made in a scratch directory of this process's own, named relative to it
scratch = "/tmp/sp_dirh_#{Process.pid}"
Dir.mkdir(scratch) unless Dir.exist?(scratch)
Dir.chdir(scratch)
dir = "sp_dirh"
Dir.mkdir(dir) unless Dir.exist?(dir)
File.write("#{dir}/x", "")
File.write("#{dir}/y", "")
d = Dir.new(dir)
p d.class
p d.path
e = []
d.each { |n| e << n }
p e.sort
d.rewind
p d.read.class
d.close
p Dir.open(dir).class
r = Dir.open(dir) { |dd| dd.children.sort }
p r
p((Dir.new("/nonexistent_zz") rescue $!.class))
cs = []
d2 = Dir.new(dir)
d2.each_child { |n| cs << n }
p cs.sort
p d2.entries.sort
d2.close
File.delete("#{dir}/x", "#{dir}/y")
Dir.rmdir(dir)
Dir.chdir("/")
Dir.rmdir(scratch)
puts "done"
