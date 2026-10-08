# Find.find walks each path top-down: a directory comes before its entries,
# entries in sorted order, dotfiles included. A file given as a path is
# yielded alone.
require "find"

def make_tree(root)
  Dir.mkdir(root)
  Dir.mkdir("#{root}/b")
  Dir.mkdir("#{root}/b/c")
  File.write("#{root}/a.txt", "x")
  File.write("#{root}/.dot", "x")
  File.write("#{root}/b/c/d.rb", "x")
end

def remove_tree(root)
  File.delete("#{root}/b/c/d.rb", "#{root}/a.txt", "#{root}/.dot")
  Dir.rmdir("#{root}/b/c")
  Dir.rmdir("#{root}/b")
  Dir.rmdir(root)
end

def walk(root)
  Find.find(root) { |f| puts f.sub(root, "ROOT") }
  puts "--"
  Find.find("#{root}/b", "#{root}/a.txt") { |f| puts f.sub(root, "ROOT") }
end

root = "/tmp/spinel_find_traversal_#{Process.pid}"
make_tree(root)
walk(root)
remove_tree(root)
