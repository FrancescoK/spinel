# A starting path may be any object with to_path, such as a Pathname: it is
# read through to_path, and the paths yielded are Strings.
require "find"
require "pathname"

def walk(root)
  Find.find(Pathname.new(root)) { |f| p [f.class, f.sub(root, "ROOT")] }
end

root = "/tmp/spinel_find_pathname_#{Process.pid}"
Dir.mkdir(root)
File.write("#{root}/a.txt", "x")
walk(root)
File.delete("#{root}/a.txt")
Dir.rmdir(root)
