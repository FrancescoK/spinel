# The filesystem half of Pathname: predicates, stat, read/write, directory
# contents, and the tree operations.
require "pathname"

root = Pathname.new("/tmp/spinel_pn_test_#{Process.pid}")
root.rmtree if root.exist?

# mkpath creates every missing ancestor
deep = root + "a/b/c"
deep.mkpath
puts deep.directory?
puts (root + "a").directory?

f = deep + "hello.txt"
f.write("one\ntwo\n")
puts f.file?
puts f.exist?
puts f.directory?
puts f.size
puts f.zero?
puts f.read
puts f.readlines.length
puts f.extname
puts f.basename.to_s
puts f.dirname.relative_path_from(root).to_s
puts f.ftype
puts f.mtime.class.to_s
puts f.stat.file?
puts f.stat.size
puts f.lstat.class.to_s

n = 0
f.each_line { |_| n += 1 }
puts n

puts(f.open { |io| io.gets })

f.binwrite("ab")
puts f.binread.bytesize

# children are full paths and sorted; entries are bare names
(deep + "z.txt").write("z")
puts deep.children.map { |c| c.basename.to_s }.inspect
puts deep.entries.map { |e| e.to_s }.sort.inspect
puts deep.empty?
puts (deep + "z.txt").empty?

seen = []
deep.each_child { |c| seen.push(c.basename.to_s) }
puts seen.sort.inspect

# glob is rooted at the directory
puts deep.glob("*.txt").map { |g| g.basename.to_s }.sort.inspect

# find walks the whole tree, receiver first
found = []
root.find { |x| found.push(x.relative_path_from(root).to_s) }
puts found.sort.inspect

# realpath resolves to something absolute
puts f.realpath.absolute?

# rename, delete
g = deep + "renamed.txt"
f.rename(g)
puts g.exist?
puts f.exist?
g.delete
puts g.exist?

# rmtree takes the whole tree down
root.rmtree
puts root.exist?
