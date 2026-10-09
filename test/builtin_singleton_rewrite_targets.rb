# spinel: share
# spinel: gc-minor
# The written method chooses the target before a builtin rewrites the call.
# Direct singleton definitions need no enclosing class or module body.
require "tmpdir"
scratch_dir = Dir.tmpdir
def File.read(path) = "user-read"
def File.open(path) = "user-open"
def File.readlines(path) = ["user-lines"]
def File.stat(path) = "user-stat"
def Dir.glob(path) = ["user-glob"]
def Dir.pwd = "user-pwd"
def Dir.rmdir(path) = "user-rmdir"
def Math.sqrt(value) = value + 1
class << File
  def writable?(path) = "user-writable"
end
path = File.join(scratch_dir, "spinel_singleton_rewrite_#{Process.pid}.txt")
File.write(path, "one\ntwo\n")
p File.read(path)
p IO.read(path)
p File.open(path)
p open(path) { |io| io.read }
File.foreach(path, chomp: true) { |line| p line }
p File.foreach(path).to_a
p File::Stat.new(path).size
p File.stat(path)
p File.writable?(path)
p Dir.glob(path)
p Dir[path].size
p Dir.getwd == "user-pwd"
p Math.sqrt(4)
File.delete(path)
dir = path + ".dir"
Dir.mkdir(dir)
p Dir.delete(dir)
p Dir.exist?(dir)

def File.size(value)
  yield value + 4
end
def Math.cos(value)
  yield value + 2
end
def Dir.empty?(value)
  yield value + 3
end
p File.size(3) { |n| n * 2 }
p Math.cos(3) { |n| n * 2 }
p Dir.empty?(3) { |n| n * 2 }
