require "tmpdir"

# A #to_path answering a boxed String that sits in a shared handle (here an
# Array element) still names the path File.read opens.
class PathLike
  def initialize(base)
    @base = base
  end

  def to_path
    @base
  end
end

def size_at(path)
  File.read(path).size
end

file = File.join(Dir.tmpdir, "sp_to_path_boxed_shared_string_#{Process.pid}.txt")
File.write(file, "hello")
base = [file, 1][0]
puts size_at(PathLike.new(base))
puts size_at(file)
File.delete(file)
