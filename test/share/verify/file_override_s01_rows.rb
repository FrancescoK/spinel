require "tmpdir"
def mut(s) = s << "x"
dir = Dir.tmpdir
a = +File.join(dir, "share_verify_file_#{Process.pid}.txt")
File.write(a, "hello")
b = a
p File.size?(a)
p FileTest.size?(a)
p File.size(a)
p File.identical?(a, b)
p FileTest.identical?(a, b.dup)
p File.zero?(a)
p File.empty?(a)
p FileTest.empty?(a)
c = a.dup
r = File.size?(c)
mut(c)
p c.end_with?("x"), a.end_with?("x"), r
p File.size?(c)
p File.exist?(c)
p FileTest.exist?(a)
p File.world_readable?(a).class
p File.absolute_path?(a)
File.delete(a)
p File.size?(a)
