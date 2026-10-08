# Find.prune inside the block skips the rest of the current directory: its
# entries are not visited, and the walk goes on with the next path.
require "find"

def make_tree(root)
  Dir.mkdir(root)
  Dir.mkdir("#{root}/keep")
  Dir.mkdir("#{root}/skip")
  File.write("#{root}/keep/a.rb", "x")
  File.write("#{root}/skip/b.rb", "x")
  File.write("#{root}/c.rb", "x")
end

def remove_tree(root)
  File.delete("#{root}/keep/a.rb", "#{root}/skip/b.rb", "#{root}/c.rb")
  Dir.rmdir("#{root}/keep")
  Dir.rmdir("#{root}/skip")
  Dir.rmdir(root)
end

def ruby_files(root)
  found = []
  Find.find(root) do |f|
    Find.prune if File.basename(f) == "skip"
    found << f.sub(root, "ROOT") if f.end_with?(".rb")
  end
  found
end

root = "/tmp/spinel_find_prune_#{Process.pid}"
make_tree(root)
p ruby_files(root)
remove_tree(root)
