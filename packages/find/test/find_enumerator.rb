# Find.find with no block returns an Enumerator over the same paths, in the
# same order, so Enumerable methods and external iteration work on it.
require "find"

def make_tree(root)
  Dir.mkdir(root)
  Dir.mkdir("#{root}/sub")
  File.write("#{root}/a.txt", "x")
  File.write("#{root}/sub/b.rb", "x")
end

def remove_tree(root)
  File.delete("#{root}/a.txt", "#{root}/sub/b.rb")
  Dir.rmdir("#{root}/sub")
  Dir.rmdir(root)
end

def use(root)
  e = Find.find(root)
  p e.class
  p e.map { |f| f.sub(root, "ROOT") }
  p e.select { |f| f.end_with?(".rb") }.map { |f| File.basename(f) }
  p e.count
  p e.first.sub(root, "ROOT")
  p e.next.sub(root, "ROOT")
  p e.next.sub(root, "ROOT")
  p Find.find(root, ignore_error: false).to_a.size
end

root = "/tmp/spinel_find_enumerator_#{Process.pid}"
make_tree(root)
use(root)
remove_tree(root)
