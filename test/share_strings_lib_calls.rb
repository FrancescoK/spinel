# A library class method (File, Dir, ...) and a C-bound class's method
# (StringIO) copy what they are handed and answer Strings of their own: the
# Strings they answer are not the caller's, and appending to one changes no
# other name.
require "stringio"
require "tmpdir"
path = +File.join(Dir.tmpdir, "sp_share_lib_#{Process.pid}")
base = File.basename(path)
base << "!"
p base.end_with?("!"), path.end_with?("!")
dir = File.dirname(path); dir2 = dir; dir2 << "/x"
p dir.end_with?("/x"), path.include?("/x")
io = StringIO.new(+"l1\nl2\n")
a = io.gets; b = a; b << "?"
p a, io.gets
lines = []
StringIO.new(+"x\ny\n").each_line { |l| l << "*"; lines << l }
p lines
File.write(path, "data")
s = File.read(path); t = s; t << "+"
p s, File.read(path)
File.delete(path)
