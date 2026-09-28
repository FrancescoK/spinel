# A Dir read out of a container answers path, to_path, read, tell, pos, fileno
# and close as a typed Dir does, where the IO arm claimed the names and raised.
dir = "/tmp/spinel_boxed_dir_#{Process.pid}"
Dir.mkdir(dir)
d = [Dir.open(dir), 0][0]
p d.path == dir
p d.to_path == dir
p [".", ".."].include?(d.read)
p d.tell.is_a?(Integer)
p d.pos == d.tell
p d.fileno.is_a?(Integer)
p d.close
# a File beside it still answers through the IO arm
File.write(dir + "/f.txt", "abc")
f = [File.open(dir + "/f.txt"), 0][0]
p f.path == dir + "/f.txt"
p f.read
p f.tell
f.close
File.delete(dir + "/f.txt")
Dir.rmdir(dir)
