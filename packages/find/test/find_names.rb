# Each directory is listed in the filesystem encoding, so a name with
# non-ASCII characters comes back as a UTF-8 String. An empty directory is
# yielded with nothing under it, and a starting path that ends in "/" is
# joined to its entries without a second "/".
require "find"

def walk(root, start)
  Find.find(start) { |f| puts f.sub(root, "ROOT") }
end

root = "/tmp/spinel_find_names_#{Process.pid}"
Dir.mkdir(root)
Dir.mkdir("#{root}/empty")
File.write("#{root}/café.txt", "x")
walk(root, root)
puts "--"
walk(root, "#{root}/")
puts "--"
p Find.find(root).map(&:encoding).uniq
p Find.find(root).select { |f| f.end_with?(".txt") }.map { |f| File.basename(f) }
File.delete("#{root}/café.txt")
Dir.rmdir("#{root}/empty")
Dir.rmdir(root)
