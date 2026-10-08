# Find.find does not follow a symbolic link to a directory: the link is
# yielded as one path, and so is a link whose target is missing. A link
# given as the starting path is yielded alone.
require "find"

def walk(root, start)
  Find.find(start) { |f| puts f.sub(root, "ROOT") }
end

root = "/tmp/spinel_find_symlink_#{Process.pid}"
Dir.mkdir(root)
Dir.mkdir("#{root}/real")
File.write("#{root}/real/f.txt", "x")
File.symlink("#{root}/real", "#{root}/link")
File.symlink("#{root}/nowhere", "#{root}/broken")
walk(root, root)
puts "--"
walk(root, "#{root}/link")
File.delete("#{root}/link", "#{root}/broken", "#{root}/real/f.txt")
Dir.rmdir("#{root}/real")
Dir.rmdir(root)
