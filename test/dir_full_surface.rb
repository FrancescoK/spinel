# Dir surface (#2822-#2830): foreach/each_child ride entries/children + .each,
# a chdir block splices with save/restore and returns the block's value, a bare
# chdir goes home, getwd/Dir[]/delete/unlink are aliases, empty? stats the
# path (ENOENT for a missing one), home(user) reads the passwd db, and glob
# takes an Array of patterns.
dir = "/tmp/sp_t_dir1_#{Process.pid}"
Dir.mkdir(dir) unless Dir.exist?(dir)
File.write("#{dir}/x", "")
a = []; Dir.foreach(dir) { |e| a << e }; p a.sort
b = []; Dir.each_child(dir) { |e| b << e }; p b
p Dir.empty?(dir)
File.delete("#{dir}/x")
p Dir.empty?(dir)
r0 = (Dir.empty?("/tmp/sp_no_such_dir_xyz_#{Process.pid}") rescue $!.class); p r0
File.write("/tmp/sp_t_dir1_file_#{Process.pid}", "x")
p Dir.empty?("/tmp/sp_t_dir1_file_#{Process.pid}") rescue p :file_missing
File.delete("/tmp/sp_t_dir1_file_#{Process.pid}")
g = []; File.write("#{dir}/a1", ""); File.write("#{dir}/a2", "")
Dir.glob("#{dir}/*") { |e| g << e.sub("#{dir}/", "") }; p g.sort
p Dir.glob(["#{dir}/a1", "#{dir}/a2"]).sort.map { |x| x.sub("#{dir}/", "") }
p(Dir.chdir("/tmp") { 42 })
p Dir.getwd.class
p Dir["#{dir}/*"].sort.length
Dir.mkdir("#{dir}/del")
r = (Dir.delete("#{dir}/del") rescue $!.class); p r
p Dir.exist?("#{dir}/del")
o = Dir.pwd
Dir.chdir
p Dir.pwd == ENV["HOME"]
Dir.chdir(o)
p Dir.home(ENV["USER"]).class
File.delete("#{dir}/a1"); File.delete("#{dir}/a2"); Dir.rmdir(dir)
d001 = "/tmp/sp_t_glob_multi_#{Process.pid}"
Dir.mkdir(d001) unless Dir.exist?(d001)
Dir.mkdir("#{d001}/sub") unless Dir.exist?("#{d001}/sub")
File.write("#{d001}/top.txt", "")
File.write("#{d001}/sub/deep.txt", "")
p Dir.glob(["#{d001}/*.txt", "#{d001}/sub/*.txt"]).sort.map { |x| x.sub("#{d001}/", "") }
p Dir.glob("#{d001}/*", File::FNM_DOTMATCH).sort.map { |x| x.sub("#{d001}/", "") }
File.delete("#{d001}/top.txt"); File.delete("#{d001}/sub/deep.txt")
Dir.rmdir("#{d001}/sub"); Dir.rmdir(d001)
